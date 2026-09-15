import SwiftUI
import SwiftData

private enum TeachPhase {
    case input
    case processing
    case overview
    case steps
    case completion
}

struct TeachFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let guideService: TeachGuideService = StubTeachGuideService()

    @State private var phase: TeachPhase = .input
    @State private var selectedImage: UIImage?
    @State private var typedText = ""
    @State private var generatedGuide: GeneratedGuide?
    @State private var isSaved = false

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
        Task {
            do {
                let guide = try await guideService.generateGuide(text: typedText, hasImage: selectedImage != nil)
                generatedGuide = guide
                phase = .overview
            } catch {
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
    TeachFlowView()
        .modelContainer(for: SavedGuide.self, inMemory: true)
}
