import SwiftUI
import SwiftData

private enum TeachPhase {
    case input
    case processing
    case declined
    case overview
    case steps
    case completion
}

struct TeachFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let guideService: TeachGuideService

    @State private var phase: TeachPhase = .input
    @State private var selectedImage: UIImage?
    @State private var typedText = ""
    @State private var generatedGuide: GeneratedGuide?
    @State private var isSaved = false
    @State private var errorMessage: String?

    init(guideService: TeachGuideService = TeachGuideServiceFactory.make()) {
        self.guideService = guideService
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        LeftyIconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                            dismiss()
                        }
                    }
                }
                .alert(
                    String(localized: "Couldn't make this left-handed"),
                    isPresented: Binding(
                        get: { errorMessage != nil },
                        set: { if !$0 { errorMessage = nil } }
                    )
                ) {
                    Button(String(localized: "OK"), role: .cancel) {
                        errorMessage = nil
                    }
                } message: {
                    Text(errorMessage ?? "")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .input:
            TeachInputPhaseView(
                selectedImage: $selectedImage,
                typedText: $typedText,
                onGenerate: generate
            )
        case .processing:
            TeachProcessingPhaseView()
        case .declined:
            if let generatedGuide {
                TeachDeclinedPhaseView(guide: generatedGuide, onTryAgain: { phase = .input })
            }
        case .overview:
            if let generatedGuide {
                TeachOverviewPhaseView(guide: generatedGuide, onStart: { phase = .steps })
            }
        case .steps:
            if let generatedGuide {
                TeachStepsPhaseView(guide: generatedGuide, onComplete: { phase = .completion })
            }
        case .completion:
            TeachCompletionPhaseView(isSaved: isSaved, onSave: save, onDone: { dismiss() })
        }
    }

    private func generate() {
        phase = .processing
        errorMessage = nil
        Task {
            do {
                let guide = try await guideService.generateGuide(
                    text: typedText,
                    image: selectedImage
                )
                generatedGuide = guide
                switch guide.confidence {
                case .needMoreInfo, .unsafe:
                    phase = .declined
                case .high, .uncertain:
                    phase = .overview
                }
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? String(localized: "Something went wrong. Try again.")
                phase = .input
            }
        }
    }

    private func save() {
        guard let generatedGuide else { return }
        modelContext.insert(SavedGuide(title: generatedGuide.title, steps: generatedGuide.steps))
        isSaved = true
    }
}

#Preview {
    TeachFlowView(guideService: StubTeachGuideService())
        .modelContainer(for: SavedGuide.self, inMemory: true)
}
