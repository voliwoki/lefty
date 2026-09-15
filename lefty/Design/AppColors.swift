import SwiftUI

enum AppColors {
    static let background = Color(
        light: Color(red: 0.94, green: 0.93, blue: 0.98),
        dark: Color(red: 0.09, green: 0.09, blue: 0.11)
    )

    static let surface = Color(
        light: .white,
        dark: Color(red: 0.15, green: 0.15, blue: 0.17)
    )

    static let primaryText = Color(
        light: Color(red: 0.13, green: 0.12, blue: 0.16),
        dark: Color(red: 0.95, green: 0.95, blue: 0.97)
    )

    static let secondaryText = Color(
        light: Color(red: 0.45, green: 0.44, blue: 0.5),
        dark: Color(red: 0.65, green: 0.65, blue: 0.68)
    )

    static let accent = Color(
        light: Color(red: 0.98, green: 0.44, blue: 0.28),
        dark: Color(red: 0.98, green: 0.5, blue: 0.34)
    )

    static let highlight = Color(
        light: Color(red: 0.99, green: 0.78, blue: 0.25),
        dark: Color(red: 0.95, green: 0.75, blue: 0.3)
    )

    static let separator = Color(
        light: Color(red: 0.88, green: 0.87, blue: 0.92),
        dark: Color(red: 0.24, green: 0.24, blue: 0.27)
    )

    static let brandPurple = Color(
        light: Color(red: 0.4, green: 0.34, blue: 0.75),
        dark: Color(red: 0.62, green: 0.56, blue: 0.95)
    )

    static let chipYellowBg = Color(
        light: Color(red: 1.0, green: 0.92, blue: 0.72),
        dark: Color(red: 0.4, green: 0.34, blue: 0.15)
    )
    static let chipYellowFg = Color(
        light: Color(red: 0.55, green: 0.4, blue: 0.05),
        dark: Color(red: 0.98, green: 0.85, blue: 0.5)
    )

    static let chipPurpleBg = Color(
        light: Color(red: 0.85, green: 0.83, blue: 0.96),
        dark: Color(red: 0.28, green: 0.24, blue: 0.42)
    )
    static let chipPurpleFg = Color(
        light: Color(red: 0.4, green: 0.34, blue: 0.75),
        dark: Color(red: 0.78, green: 0.74, blue: 0.98)
    )

    static let chipPinkBg = Color(
        light: Color(red: 1.0, green: 0.85, blue: 0.82),
        dark: Color(red: 0.42, green: 0.2, blue: 0.19)
    )
    static let chipPinkFg = Color(
        light: Color(red: 0.78, green: 0.32, blue: 0.28),
        dark: Color(red: 0.98, green: 0.68, blue: 0.63)
    )

    static let chipGreenBg = Color(
        light: Color(red: 0.82, green: 0.93, blue: 0.83),
        dark: Color(red: 0.16, green: 0.32, blue: 0.2)
    )
    static let chipGreenFg = Color(
        light: Color(red: 0.22, green: 0.53, blue: 0.29),
        dark: Color(red: 0.68, green: 0.9, blue: 0.72)
    )
}

private extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
