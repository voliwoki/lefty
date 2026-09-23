import Foundation

enum OnboardingAudience: String, CaseIterable, Identifiable {
    case me
    case myKid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .me: String(localized: "For me")
        case .myKid: String(localized: "For my kid")
        }
    }

    var subtitle: String {
        switch self {
        case .me: String(localized: "I'm left-handed and want things to finally make sense.")
        case .myKid: String(localized: "I'm helping a left-handed kid I care about.")
        }
    }

    var symbolName: String {
        switch self {
        case .me: "hand.raised.fill"
        case .myKid: "figure.and.child.holdinghands"
        }
    }
}

struct OnboardingPageContent: Identifiable, Equatable {
    let id: String
    let symbolName: String
    let headline: String
    let body: String
    let primaryCTA: String
}

enum OnboardingCopy {
    static var identityHeadline: String {
        String(localized: "Who is Lefty for?")
    }

    static var identityBody: String {
        String(localized: "We'll speak to your world — then show how Lefty helps.")
    }

    static var identityCTA: String {
        String(localized: "Continue")
    }

    static var skipTitle: String {
        String(localized: "Skip")
    }

    static func contentPages(for audience: OnboardingAudience) -> [OnboardingPageContent] {
        switch audience {
        case .me:
            [
                OnboardingPageContent(
                    id: "me-wound",
                    symbolName: "globe.americas.fill",
                    headline: String(localized: "The world was built for the other hand."),
                    body: String(localized: "Scissors, notebooks, knots, tools — most how-tos assume a right hand. You're not clumsy. The instructions are."),
                    primaryCTA: String(localized: "That's me")
                ),
                OnboardingPageContent(
                    id: "me-fomo",
                    symbolName: "person.3.fill",
                    headline: String(localized: "Peers make it look easy."),
                    body: String(localized: "They finish the craft, tie the tie, write without smudging. You feel left out — not because you can't learn, but because nobody showed your hand."),
                    primaryCTA: String(localized: "Keep going")
                ),
                OnboardingPageContent(
                    id: "me-stuck",
                    symbolName: "exclamationmark.bubble.fill",
                    headline: String(localized: "Frustration is loud. Help is quiet."),
                    body: String(localized: "You search, reverse the steps in your head, still get stuck. That knot in your stomach? Lefty is built for that moment."),
                    primaryCTA: String(localized: "Show me the fix")
                ),
                OnboardingPageContent(
                    id: "me-solution",
                    symbolName: "camera.fill",
                    headline: String(localized: "Same world. Just left."),
                    body: String(localized: "Photo or type any right-handed how-to. Lefty rewrites it into clear left-handed steps you can follow — and save for next time."),
                    primaryCTA: String(localized: "Unlock Lefty+")
                ),
            ]
        case .myKid:
            [
                OnboardingPageContent(
                    id: "kid-wound",
                    symbolName: "globe.americas.fill",
                    headline: String(localized: "The world was built for the other hand."),
                    body: String(localized: "Classroom scissors, worksheets, sports drills — most instructions assume a right hand. Your kid isn't behind. The materials are."),
                    primaryCTA: String(localized: "I see it")
                ),
                OnboardingPageContent(
                    id: "kid-fomo",
                    symbolName: "person.3.fill",
                    headline: String(localized: "They watch friends do it first."),
                    body: String(localized: "Tying shoes, cutting paper, handwriting that doesn't smear. Feeling left out hits hard when everyone else seems to get it."),
                    primaryCTA: String(localized: "Keep going")
                ),
                OnboardingPageContent(
                    id: "kid-stuck",
                    symbolName: "heart.fill",
                    headline: String(localized: "You can do it. Teaching it left-handed? Blank."),
                    body: String(localized: "Parents freeze mid-lesson — mirroring feels wrong, YouTube assumes the wrong hand. You want to help. You just need steps for their hand."),
                    primaryCTA: String(localized: "Show me the fix")
                ),
                OnboardingPageContent(
                    id: "kid-solution",
                    symbolName: "camera.fill",
                    headline: String(localized: "Same world. Just left."),
                    body: String(localized: "Snap a worksheet or type the skill. Lefty turns it into left-handed steps you can teach together — calm, clear, and saveable."),
                    primaryCTA: String(localized: "Unlock Lefty+")
                ),
            ]
        }
    }
}
