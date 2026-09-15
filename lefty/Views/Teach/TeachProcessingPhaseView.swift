import SwiftUI

struct TeachProcessingPhaseView: View {
    private let messages = [
        "Reading the instructions…",
        "Finding what changes for a lefty…",
        "Building your guide…"
    ]
    @State private var messageIndex = 0

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.accent)
            Text(messages[messageIndex])
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
                .id(messageIndex)
                .transition(.opacity)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColors.background)
        .task {
            for _ in 0..<20 {
                try? await Task.sleep(for: .seconds(0.9))
                withAnimation {
                    messageIndex = (messageIndex + 1) % messages.count
                }
            }
        }
    }
}

#Preview {
    TeachProcessingPhaseView()
}
