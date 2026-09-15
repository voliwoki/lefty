import Foundation
import UIKit
import OSLog

enum TeachGuideServiceError: Error, LocalizedError {
    case missingSecrets
    case invalidResponse
    case serverError(status: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingSecrets:
            return String(localized: "Teach is not configured. Add Secrets.plist (see Secrets.example.plist).")
        case .invalidResponse:
            return String(localized: "Couldn't read the guide response.")
        case .serverError:
            return String(localized: "Couldn't make this left-handed right now. Try again.")
        case .decodingFailed:
            return String(localized: "The guide came back in an unexpected format.")
        }
    }
}

struct RemoteTeachGuideService: TeachGuideService {
    private let secrets: AppSecrets.Values
    private let session: URLSession
    private let logger = Logger(subsystem: "com.knk.lefty", category: "TeachGuide")

    init(secrets: AppSecrets.Values, session: URLSession = .shared) {
        self.secrets = secrets
        self.session = session
    }

    func generateGuide(text: String, image: UIImage?) async throws -> GeneratedGuide {
        let endpoint = secrets.teachWorkerURL.appending(path: "v1/teach")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(secrets.leftyAppSecret, forHTTPHeaderField: "X-Lefty-App-Secret")
        request.timeoutInterval = 90

        var body: [String: Any] = ["schemaVersion": "1"]
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            body["text"] = trimmed
        }

        if let image,
           let jpeg = image.jpegData(compressionQuality: 0.7) {
            body["imageBase64"] = jpeg.base64EncodedString()
            body["mimeType"] = "image/jpeg"
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger.error("Teach network failure: \(error.localizedDescription, privacy: .public)")
            throw TeachGuideServiceError.serverError(status: -1)
        }

        guard let http = response as? HTTPURLResponse else {
            throw TeachGuideServiceError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            logger.error("Teach HTTP \(http.statusCode, privacy: .public)")
            throw TeachGuideServiceError.serverError(status: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(GeneratedGuide.self, from: data)
        } catch {
            logger.error("Teach decode failed: \(error.localizedDescription, privacy: .public)")
            throw TeachGuideServiceError.decodingFailed
        }
    }
}

enum TeachGuideServiceFactory {
    static func make() -> TeachGuideService {
        if let secrets = AppSecrets.current {
            return RemoteTeachGuideService(secrets: secrets)
        }
        #if DEBUG
        return StubTeachGuideService()
        #else
        return MissingSecretsTeachGuideService()
        #endif
    }
}

private struct MissingSecretsTeachGuideService: TeachGuideService {
    func generateGuide(text: String, image: UIImage?) async throws -> GeneratedGuide {
        throw TeachGuideServiceError.missingSecrets
    }
}
