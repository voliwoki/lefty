import SwiftUI

struct LeftyChip: View {
    let title: String
    var tone: ChipTone = .purple
    var isSelected: Bool = false

    var body: some View {
        Text(title)
            .font(AppFont.captionEmphasized)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs + 2)
            .frame(minHeight: 32)
            .background(isSelected ? tone.foreground : tone.background)
            .foregroundStyle(isSelected ? .white : tone.foreground)
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        LeftyChip(title: "All", tone: .purple, isSelected: true)
        LeftyChip(title: "Fun Fact", tone: .yellow)
        LeftyChip(title: "Struggle", tone: .pink)
        LeftyChip(title: "Win", tone: .green)
    }
    .padding()
    .background(AppColors.background)
}
