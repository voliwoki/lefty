import SwiftUI

struct TeachProcessingPhaseView: View {
    private let messages = [
        "Reading the instructions…",
        "Finding what changes for a lefty…",
        "Building your guide…"
    ]
    @State private var messageIndex = 0
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppColors.chipPurpleBg)
                    .frame(width: 96, height: 96)
                    .scaleEffect(isPulsing ? 1.12 : 0.9)
                    .opacity(isPulsing ? 0.5 : 1)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(AppColors.chipPurpleFg)
                    .symbolEffect(.bounce, options: .repeating.speed(0.4))
            }
            .accessibilityHidden(true)
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
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
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
