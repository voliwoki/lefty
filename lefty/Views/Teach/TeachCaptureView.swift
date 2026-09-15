import SwiftUI
import UIKit

private enum TeachCapturePhase {
    case live
    case review(UIImage)
}

struct TeachCaptureView: View {
    let onPhotoCaptured: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var controller = CameraSessionController()
    @State private var phase: TeachCapturePhase = .live
    @State private var captureErrorMessage: String?
    @State private var reviewAppeared = false
    @State private var shutterPulse = 0

    var body: some View {
        ZStack {
            AppColors.primaryText.ignoresSafeArea()

            switch phase {
            case .live:
                liveContent
            case .review(let image):
                reviewContent(image)
            }
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.85), trigger: shutterPulse)
        .task {
            await controller.prepare()
            if controller.availability == .ready {
                await controller.start()
            }
        }
        .onDisappear {
            Task { await controller.stop() }
        }
        .alert(
            String(localized: "Couldn't capture photo"),
            isPresented: Binding(
                get: { captureErrorMessage != nil },
                set: { if !$0 { captureErrorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK"), role: .cancel) {
                captureErrorMessage = nil
            }
        } message: {
            Text(captureErrorMessage ?? "")
        }
    }

    @ViewBuilder
    private var liveContent: some View {
        switch controller.availability {
        case .unknown:
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .ready:
            liveCamera
        case .unavailable, .denied, .restricted:
            unavailableContent
        }
    }

    private var liveCamera: some View {
        ZStack {
            if let session = controller.sessionForPreview {
                CameraPreviewView(session: session)
                    .ignoresSafeArea()
            }

            viewfinderOverlay

            VStack {
                coachBanner
                Spacer()
                bottomChrome
            }
            .padding(AppSpacing.lg)
        }
    }

    private var coachBanner: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "doc.text.viewfinder")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.highlight)
                .accessibilityHidden(true)

            Text(String(localized: "Photograph the instructions — not yourself"))
                .font(AppFont.subheadlineEmphasized)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .background(.ultraThinMaterial.opacity(0.85), in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var viewfinderOverlay: some View {
        GeometryReader { geo in
            let insetX = AppSpacing.xl
            let insetY = geo.size.height * 0.18
            let rect = CGRect(
                x: insetX,
                y: insetY,
                width: geo.size.width - insetX * 2,
                height: geo.size.height - insetY * 2 - 120
            )

            ZStack {
                Color.black.opacity(0.45)
                    .reverseMask {
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                    }
                    .allowsHitTesting(false)

                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColors.accent.opacity(0.9), lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .allowsHitTesting(false)

                viewfinderCorners(in: rect)
            }
        }
        .ignoresSafeArea()
    }

    private func viewfinderCorners(in rect: CGRect) -> some View {
        let length: CGFloat = 28
        let color = AppColors.highlight
        return ZStack {
            cornerBracket.position(x: rect.minX + length / 2, y: rect.minY + length / 2)
            cornerBracket.rotationEffect(.degrees(90)).position(x: rect.maxX - length / 2, y: rect.minY + length / 2)
            cornerBracket.rotationEffect(.degrees(-90)).position(x: rect.minX + length / 2, y: rect.maxY - length / 2)
            cornerBracket.rotationEffect(.degrees(180)).position(x: rect.maxX - length / 2, y: rect.maxY - length / 2)
        }
        .foregroundStyle(color)
        .allowsHitTesting(false)
    }

    private var cornerBracket: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 22))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 22, y: 0))
        }
        .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        .frame(width: 28, height: 28)
    }

    private var bottomChrome: some View {
        HStack(alignment: .center, spacing: AppSpacing.lg) {
            shutterButton

            Spacer()

            if controller.supportsTorch {
                Button {
                    Task { await controller.toggleTorch() }
                } label: {
                    Image(systemName: controller.torchEnabled ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    controller.torchEnabled
                        ? String(localized: "Turn flashlight off")
                        : String(localized: "Turn flashlight on")
                )
            }

            Button {
                Task {
                    await controller.stop()
                    dismiss()
                }
            } label: {
                Text(String(localized: "Close"))
                    .font(AppFont.subheadlineEmphasized)
                    .foregroundStyle(.white)
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.horizontal, AppSpacing.md)
                    .background(Capsule().fill(.ultraThinMaterial))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Close camera"))
        }
    }

    private var shutterButton: some View {
        Button {
            Task { await takePhoto() }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(.white, lineWidth: 4)
                    .frame(width: 76, height: 76)
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 62, height: 62)
            }
            .frame(width: 76, height: 76)
        }
        .buttonStyle(.plain)
        .disabled(controller.isCapturing)
        .opacity(controller.isCapturing ? 0.6 : 1)
        .accessibilityLabel(String(localized: "Take photo"))
        .accessibilityHint(String(localized: "Captures the instructions in the frame"))
    }

    private var unavailableContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            LeftyIconButton(systemImage: "xmark", accessibilityLabel: String(localized: "Close")) {
                dismiss()
            }
            .foregroundStyle(.white)

            Spacer()

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(unavailableTitle)
                    .font(AppFont.title)
                    .foregroundStyle(.white)
                Text(unavailableMessage)
                    .font(AppFont.body)
                    .foregroundStyle(.white.opacity(0.85))

                if controller.availability == .denied {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    } label: {
                        Text(String(localized: "Open Settings"))
                            .font(AppFont.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accent)
                    .controlSize(.large)
                }

                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "Upload a photo instead"))
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .controlSize(.large)
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.brandPurple.opacity(0.55))
            )

            Spacer()
        }
        .padding(AppSpacing.lg)
    }

    private var unavailableTitle: String {
        switch controller.availability {
        case .denied, .restricted:
            String(localized: "Camera access needed")
        default:
            String(localized: "Camera unavailable")
        }
    }

    private var unavailableMessage: String {
        switch controller.availability {
        case .denied, .restricted:
            String(localized: "Allow camera access to photograph instructions, or upload a photo from your library.")
        default:
            String(localized: "Camera unavailable — upload a photo instead.")
        }
    }

    private func reviewContent(_ image: UIImage) -> some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.accent.opacity(0.8), lineWidth: 2)
                )
                .padding(AppSpacing.lg)
                .scaleEffect(reviewAppeared ? 1 : 0.96)
                .opacity(reviewAppeared ? 1 : 0.7)

            Spacer(minLength: AppSpacing.md)

            LeftyActionBar(
                primaryTitle: String(localized: "Use photo"),
                primaryIcon: "checkmark",
                primaryAction: {
                    onPhotoCaptured(image)
                    dismiss()
                },
                secondaryTitle: String(localized: "Retake"),
                secondaryAction: {
                    phase = .live
                    reviewAppeared = false
                    Task { await controller.start() }
                }
            )
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                reviewAppeared = true
            }
        }
    }

    private func takePhoto() async {
        shutterPulse += 1
        do {
            let image = try await controller.capturePhoto()
            await controller.stop()
            withAnimation(.easeOut(duration: 0.2)) {
                phase = .review(image)
            }
        } catch {
            captureErrorMessage = String(localized: "Something went wrong capturing the photo. Try again.")
        }
    }
}

private extension View {
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle()
                .overlay {
                    mask()
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
        }
    }
}

#Preview {
    TeachCaptureView(onPhotoCaptured: { _ in })
}
