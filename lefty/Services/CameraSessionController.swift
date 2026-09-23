import AVFoundation
import OSLog
import UIKit

enum CameraAvailability: Equatable {
    case unknown
    case ready
    case unavailable
    case denied
    case restricted
}

/// Owns the AVCaptureSession off the main actor.
actor CaptureSessionEngine {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var deviceInput: AVCaptureDeviceInput?
    private let logger = Logger(subsystem: "com.knk.lefty", category: "CameraEngine")

    var supportsTorch: Bool {
        deviceInput?.device.hasTorch == true && deviceInput?.device.isTorchAvailable == true
    }

    func configure() -> Bool {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        if let existing = deviceInput {
            session.removeInput(existing)
            deviceInput = nil
        }
        session.outputs.forEach { session.removeOutput($0) }

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(photoOutput)
        else {
            logger.error("Unable to add camera input/output")
            return false
        }

        session.addInput(input)
        session.addOutput(photoOutput)
        deviceInput = input
        return true
    }

    func start() {
        guard !session.isRunning else { return }
        session.startRunning()
    }

    func stop() {
        guard session.isRunning else { return }
        session.stopRunning()
        setTorch(enabled: false)
    }

    @discardableResult
    func setTorch(enabled: Bool) -> Bool {
        guard
            let device = deviceInput?.device,
            device.hasTorch,
            device.isTorchAvailable
        else {
            return false
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
            return enabled
        } catch {
            logger.error("Torch failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    func makePhotoSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(.auto) {
            settings.flashMode = .auto
        }
        return settings
    }

    func capturePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        photoOutput.capturePhoto(with: makePhotoSettings(), delegate: delegate)
    }
}

@MainActor
@Observable
final class CameraSessionController: NSObject {
    private(set) var availability: CameraAvailability = .unknown
    private(set) var isSessionRunning = false
    private(set) var isCapturing = false
    private(set) var torchEnabled = false
    private(set) var supportsTorch = false

    private let engine = CaptureSessionEngine()
    private var captureContinuation: CheckedContinuation<UIImage, Error>?
    private let logger = Logger(subsystem: "com.knk.lefty", category: "Camera")

    /// Bound to the preview layer after `prepare()` succeeds.
    private(set) var sessionForPreview: AVCaptureSession?

    enum CaptureError: Error {
        case notReady
        case captureFailed
    }

    func prepare() async {
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil else {
            availability = .unavailable
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await finishConfiguration()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                await finishConfiguration()
            } else {
                availability = .denied
            }
        case .denied:
            availability = .denied
        case .restricted:
            availability = .restricted
        @unknown default:
            availability = .unavailable
        }
    }

    func start() async {
        guard availability == .ready, !isSessionRunning else { return }
        await engine.start()
        isSessionRunning = true
    }

    func stop() async {
        guard isSessionRunning || torchEnabled else { return }
        await engine.stop()
        isSessionRunning = false
        torchEnabled = false
    }

    func toggleTorch() async {
        let next = !torchEnabled
        torchEnabled = await engine.setTorch(enabled: next)
    }

    func capturePhoto() async throws -> UIImage {
        guard availability == .ready, !isCapturing else {
            throw CaptureError.notReady
        }
        isCapturing = true
        defer { isCapturing = false }

        return try await withCheckedThrowingContinuation { continuation in
            captureContinuation = continuation
            Task {
                await engine.capturePhoto(delegate: self)
            }
        }
    }

    private func finishConfiguration() async {
        let ok = await engine.configure()
        if ok {
            sessionForPreview = await engine.session
            supportsTorch = await engine.supportsTorch
            availability = .ready
        } else {
            logger.error("Failed to configure capture session")
            availability = .unavailable
        }
    }
}

extension CameraSessionController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            let continuation = captureContinuation
            captureContinuation = nil

            if let error {
                continuation?.resume(throwing: error)
                return
            }

            guard
                let data = photo.fileDataRepresentation(),
                let image = UIImage(data: data)
            else {
                continuation?.resume(throwing: CaptureError.captureFailed)
                return
            }

            continuation?.resume(returning: image)
        }
    }
}
