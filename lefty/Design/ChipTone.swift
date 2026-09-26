import SwiftUI

enum ChipTone {
    case yellow, purple, pink, green, blue

    var background: Color {
        switch self {
        case .yellow: AppColors.chipYellowBg
        case .purple: AppColors.chipPurpleBg
        case .pink: AppColors.chipPinkBg
        case .green: AppColors.chipGreenBg
        case .blue: AppColors.chipBlueBg
        }
    }

    var foreground: Color {
        switch self {
        case .yellow: AppColors.chipYellowFg
        case .purple: AppColors.chipPurpleFg
        case .pink: AppColors.chipPinkFg
        case .green: AppColors.chipGreenFg
        case .blue: AppColors.chipBlueFg
        }
    }
}
