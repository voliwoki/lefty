import CoreText
import Foundation

enum FontRegistrar {
    private static let fontFileNames = [
        "Fredoka-Regular",
        "Fredoka-SemiBold",
        "Fredoka-Bold",
        "ReenieBeanie-Regular"
    ]

    static func registerBundledFonts() {
        for name in fontFileNames {
            let url = Bundle.main.url(forResource: name, withExtension: "ttf")
                ?? Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
            guard let url else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
