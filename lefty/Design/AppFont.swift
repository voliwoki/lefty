import SwiftUI

enum AppFont {
    private enum FontName {
        static let regular = "Fredoka-Regular"
        static let semiBold = "Fredoka-SemiBold"
        static let bold = "Fredoka-Bold"
        static let logo = "ReenieBeanie"
    }

    static let largeTitle = Font.custom(FontName.bold, size: 34, relativeTo: .largeTitle)
    static let title = Font.custom(FontName.bold, size: 22, relativeTo: .title2)
    static let headline = Font.custom(FontName.semiBold, size: 17, relativeTo: .headline)
    static let body = Font.custom(FontName.regular, size: 17, relativeTo: .body)
    static let subheadline = Font.custom(FontName.regular, size: 15, relativeTo: .subheadline)
    static let subheadlineEmphasized = Font.custom(FontName.semiBold, size: 15, relativeTo: .subheadline)
    static let caption = Font.custom(FontName.regular, size: 12, relativeTo: .caption)
    static let captionEmphasized = Font.custom(FontName.semiBold, size: 12, relativeTo: .caption)

    static func logo(size: CGFloat) -> Font {
        Font.custom(FontName.logo, size: size, relativeTo: .largeTitle)
    }
}
