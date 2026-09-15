import Foundation
import UIKit

protocol TeachGuideService {
    func generateGuide(text: String, image: UIImage?) async throws -> GeneratedGuide
}

struct StubTeachGuideService: TeachGuideService {
    func generateGuide(text: String, image: UIImage?) async throws -> GeneratedGuide {
        try await Task.sleep(for: .seconds(2))

        let lowercased = text.lowercased()

        if lowercased.contains("scissor") {
            return .scissorsExample
        } else if lowercased.contains("guitar") {
            return .guitarExample
        } else if lowercased.contains("knit") {
            return .knittingExample
        } else if lowercased.contains("knife") || lowercased.contains("kitchen") || lowercased.contains("cook") || lowercased.contains("chop") {
            return .kitchenExample
        } else if lowercased.contains("write") || lowercased.contains("pen") || lowercased.contains("pencil") || lowercased.contains("handwrit") {
            return .writingExample
        } else {
            return .genericExample(for: text)
        }
    }
}

private extension GeneratedGuide {
    static let scissorsExample = GeneratedGuide(
        title: "Left-Handed Scissors",
        estimatedMinutes: 3,
        summary: "Right-handed scissors hide your cutting line. Here's how to fix that.",
        whatChanges: "Which side the blade sits on, and which hand leads the cut.",
        whatStaysSame: "The squeeze-and-release motion itself.",
        confidence: .high,
        clarifyingQuestion: nil,
        steps: [
            GuideStep(number: 1, instruction: "Use left-handed scissors if you have them — the blade order is reversed so your cutting line stays visible."),
            GuideStep(number: 2, instruction: "Keep the blade on the right side of your hand so the top blade pushes material out of your view as you cut."),
            GuideStep(number: 3, instruction: "Cut in short, controlled strokes rather than forcing the scissors through in one go."),
            GuideStep(number: 4, instruction: "With only right-handed scissors on hand, turn the paper instead of the scissors, and cut close to your body for more control.")
        ],
        safetyNote: nil
    )

    static let guitarExample = GeneratedGuide(
        title: "Left-Handed Guitar Basics",
        estimatedMinutes: 6,
        summary: "There's no single right way to play left-handed — here are your real options.",
        whatChanges: "Which hand frets and which hand strums, if you restring.",
        whatStaysSame: "Chord shapes, rhythm, and the instrument itself.",
        confidence: .high,
        clarifyingQuestion: nil,
        steps: [
            GuideStep(number: 1, instruction: "Decide early: restring a guitar left-handed by reversing the strings, or learn right-handed and fret with your left hand as-is."),
            GuideStep(number: 2, instruction: "Try before you commit — a restrung guitar can feel different since the body shape stays right-handed."),
            GuideStep(number: 3, instruction: "Look for left-handed-specific lessons, since chord charts are usually mirrored for right-handed players."),
            GuideStep(number: 4, instruction: "Give it a few weeks either way. Many left-handed guitarists end up playing standard guitars comfortably.")
        ],
        safetyNote: nil
    )

    static let knittingExample = GeneratedGuide(
        title: "Left-Handed Knitting",
        estimatedMinutes: 8,
        summary: "Mirror the motion, not the confusion — here's the fastest way in.",
        whatChanges: "Which hand holds the working needle and yarn tension.",
        whatStaysSame: "The stitch itself and the finished result.",
        confidence: .high,
        clarifyingQuestion: nil,
        steps: [
            GuideStep(number: 1, instruction: "Mirror the pattern: hold your needles and yarn as the reflection of a right-handed diagram."),
            GuideStep(number: 2, instruction: "Or try knitting right-handed patterns exactly as shown, just using your left hand for the working needle."),
            GuideStep(number: 3, instruction: "Watch mirrored video tutorials — seeing the motion clicks faster than reading text descriptions of hand swaps."),
            GuideStep(number: 4, instruction: "Practice the cast-on slowly, then build speed once the motion feels natural.")
        ],
        safetyNote: nil
    )

    static let kitchenExample = GeneratedGuide(
        title: "Left-Handed Kitchen Knife Grip",
        estimatedMinutes: 4,
        summary: "A safer, more visible cutting stance built for your left hand.",
        whatChanges: "Blade angle and which side you stand on next to a helper.",
        whatStaysSame: "The knife itself and the cutting technique.",
        confidence: .high,
        clarifyingQuestion: nil,
        steps: [
            GuideStep(number: 1, instruction: "Stand to the left of a right-handed helper when cooking together, so your elbows don't bump."),
            GuideStep(number: 2, instruction: "Curl the fingertips of your guiding hand under, using your knuckles as a guide for the blade."),
            GuideStep(number: 3, instruction: "Angle the blade slightly toward you — the mirror of typical right-handed advice — to keep your cutting line visible."),
            GuideStep(number: 4, instruction: "Look for a straight-edge chef's knife. Most work equally well for both hands.")
        ],
        safetyNote: "Go slowly while the grip still feels new — comfort with the blade comes with practice."
    )

    static let writingExample = GeneratedGuide(
        title: "Comfortable Left-Handed Writing",
        estimatedMinutes: 3,
        summary: "Small adjustments that stop smudging and hand strain.",
        whatChanges: "Paper angle and where your wrist rests.",
        whatStaysSame: "Your letter shapes and handwriting style.",
        confidence: .high,
        clarifyingQuestion: nil,
        steps: [
            GuideStep(number: 1, instruction: "Rotate your paper 30 to 45 degrees clockwise so your hand follows the line naturally instead of curling over it."),
            GuideStep(number: 2, instruction: "Hold the pen about an inch above the tip so your knuckles don't block your view of what you just wrote."),
            GuideStep(number: 3, instruction: "Rest your wrist below the line you're writing, rather than hooking over the top."),
            GuideStep(number: 4, instruction: "Try a soft, low-friction pen like a gel or rollerball — it glides instead of drags.")
        ],
        safetyNote: nil
    )

    static func genericExample(for text: String) -> GeneratedGuide {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = trimmed.isEmpty ? "this" : trimmed
        return GeneratedGuide(
            title: trimmed.isEmpty ? "Left-Handed Guide" : "Left-Handed: \(trimmed)",
            estimatedMinutes: 5,
            summary: "Here's how to approach \(subject) comfortably as a left-hander.",
            whatChanges: "Your grip, your angle, and which side you lead with.",
            whatStaysSame: "The core technique and the end result.",
            confidence: .high,
            clarifyingQuestion: nil,
            steps: [
                GuideStep(number: 1, instruction: "Turn or angle the material so your left hand has a clear, unobstructed view of your working edge."),
                GuideStep(number: 2, instruction: "Lead with your left hand and let your right hand support or steady the material — the mirror of typical right-handed instructions."),
                GuideStep(number: 3, instruction: "Go slowly for the first few tries. The motion will feel unfamiliar even though it's the mirror image of a common instruction."),
                GuideStep(number: 4, instruction: "Once the motion feels natural, build up to your normal speed. Muscle memory catches up fast.")
            ],
            safetyNote: nil
        )
    }
}
