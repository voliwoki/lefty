import SwiftUI

struct CelebrationBurst: View {
    private let pieceCount = 12
    private let colors: [Color] = [
        AppColors.accent, AppColors.highlight, AppColors.brandPurple, AppColors.chipGreenFg
    ]

    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<pieceCount, id: \.self) { index in
                piece(for: index)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animate = true
            }
        }
    }

    private func piece(for index: Int) -> some View {
        let angle = (Double(index) / Double(pieceCount)) * 2 * .pi
        let distance: CGFloat = animate ? 90 : 0
        return Circle()
            .fill(colors[index % colors.count])
            .frame(width: 8, height: 8)
            .offset(x: cos(angle) * distance, y: sin(angle) * distance)
            .opacity(animate ? 0 : 1)
    }
}

#Preview {
    CelebrationBurst()
        .frame(width: 200, height: 200)
        .background(AppColors.background)
}
