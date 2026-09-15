import Foundation

enum LearnContentLoader {
    static let guides: [GuideDocument] = {
        guard let url = Bundle.main.url(forResource: "learn_guides", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([GuideDocument].self, from: data) else {
            return []
        }
        return decoded
    }()
}
