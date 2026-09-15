---
name: ios-swiftui-best-practices
description: Use whenever building, reviewing, refactoring, or proposing implementation for the Lefty iOS app. Covers architecture, SwiftUI state management, concurrency, SwiftData, networking, RevenueCat, accessibility, design system, testing, and anti-patterns to avoid for this two-week Shipaton build.
---

# iOS + SwiftUI Best Practices — Lefty

## Purpose

Use this skill whenever building, reviewing, refactoring, or proposing implementation for the Lefty iOS app.

The goal is a polished, reliable native iPhone app built with modern Swift and SwiftUI. Prefer simple Apple-native solutions over unnecessary architecture, packages, abstractions, or infrastructure.

This is a two-week Shipaton build. Optimize for:
1. Correctness
2. Excellent native iOS UX
3. Maintainability
4. Accessibility
5. Demo reliability
6. Shipping speed

Do not over-engineer.

## Hard Technical Rules

- Native iOS only.
- Swift + SwiftUI.
- iPhone first.
- Use modern Swift concurrency.
- Use SwiftData for persistent local app data where persistence is actually needed.
- Prefer Apple frameworks before third-party packages.
- RevenueCat is allowed and required for subscriptions.
- No custom backend.
- No Firebase.
- No Supabase.
- No custom authentication.
- No user accounts.
- No community/social backend.
- No unnecessary analytics SDKs.
- No secrets or private API keys hardcoded into the app bundle.
- Do not introduce a dependency without a concrete reason.
- Do not replace working native functionality with a package simply because a package exists.

## Architecture

Keep architecture simple and feature-oriented.

Prefer:

```text
App/
Features/
    Home/
    TeachLeftHanded/
    Learn/
    Practice/
    MyLefty/
    Paywall/
Components/
Models/
Services/
Persistence/
DesignSystem/
Resources/
```

Each feature should own the views and feature-specific logic it needs.

Do not create enterprise-style layers for a small app.

Avoid:
- Massive global managers
- Service locator patterns
- Dependency injection frameworks
- Repository layers that merely wrap one SwiftData call
- Protocols with only one implementation unless they provide a real testing or architectural benefit
- Generic abstractions created before they are needed
- Huge `Utils` folders
- One enormous `ContentView.swift`
- One enormous `AppState` containing everything

A little duplication is preferable to a premature abstraction that makes the app harder to understand.

## SwiftUI State Management

Use the narrowest state ownership possible.

Use:
- `@State` for view-owned transient state
- `@Binding` when a child needs to modify state owned by its parent
- `@Environment` for genuinely shared dependencies or system values
- Observation (`@Observable`) for shared feature/application models when appropriate
- SwiftData queries/model context for persisted model data

Do not automatically create a view model for every screen.

A simple SwiftUI view with local state should remain a simple SwiftUI view.

Extract logic when:
- It is substantial
- It is reused
- It needs independent testing
- It represents a meaningful domain operation
- The view becomes difficult to reason about

Never store derived values as independent mutable state when they can be computed from the source of truth.

Avoid multiple competing sources of truth.

## Swift Concurrency

Use `async/await`.

Prefer structured concurrency.

UI-affecting observable state must be isolated appropriately to the main actor.

Handle cancellation.

A user leaving a screen should not leave unnecessary work running.

Never:
- Block the main thread with expensive work
- Use arbitrary `DispatchQueue.main.async` calls to hide state problems
- Create detached tasks without a clear reason
- Ignore thrown errors
- Fire duplicate network/AI requests because a SwiftUI view re-rendered

For user-triggered long-running operations:
1. Enter loading state
2. Start one controlled task
3. Allow cancellation where useful
4. Handle success
5. Handle failure
6. Return UI to a valid state

## SwiftData

Use SwiftData only for information worth persisting.

Good candidates:
- Saved guides
- Favorites
- Practice progress
- User preferences when appropriate
- Translation metadata/history the user explicitly keeps

Do not persist temporary UI state.

Keep models small and explicit.

Plan migrations before making destructive model changes once real user data exists.

Do not silently delete user data to solve a migration problem.

For Shipaton, keep the schema deliberately small.

## Local-First Principle

Lefty should work locally wherever the feature allows it.

Do not add cloud infrastructure for:
- Favorites
- Saved guides
- Progress
- Settings
- Onboarding state
- Cached built-in content

Built-in Learn content should ship as local structured resources where practical.

The app should remain useful when offline, except features that genuinely require an external service.

Always distinguish between:
- Local feature
- Network-required feature
- Temporarily unavailable feature

Never make the entire app unusable because one online feature fails.

## Networking

Centralize actual network request behavior rather than scattering `URLSession` calls throughout views.

Use:
- `URLSession`
- `Codable`
- `async/await`
- Typed request/response models
- Explicit errors

Do not pass raw dictionaries around.

Never trust remote output to have the expected shape.

Validate decoded data before presenting it.

Handle:
- No connection
- Timeout
- Invalid response
- Invalid data
- Rate limiting
- Service unavailable
- Cancellation

Error messages shown to users should explain what they can do next.

Bad:
> Error 429.

Better:
> Lefty is busy right now. Try again in a moment.

## API Secrets

Never ship a private provider API key directly inside the iOS app.

Obfuscating a secret inside the bundle is not security.

If a feature requires a secret server-side credential and there is no approved secure mechanism for it, flag the architectural issue rather than embedding the key.

Do not quietly violate this rule to make a demo work.

## AI Output

AI output must be treated as untrusted external data.

For Teach Me Left-Handed, prefer a strict structured response model such as:

```swift
struct LeftyGuide: Codable {
    let title: String
    let summary: String
    let category: String
    let confidence: Confidence
    let whatChanges: [String]
    let whatStaysSame: [String]
    let steps: [LeftyStep]
    let safetyLevel: SafetyLevel
}

struct LeftyStep: Codable, Identifiable {
    let id: UUID
    let number: Int
    let instruction: String
    let leftyTip: String?
    let explanation: String?
}
```

The AI supplies content.

SwiftUI controls presentation.

Never let AI-generated text define arbitrary UI hierarchy, navigation, colors, fonts, actions, or code.

Validate:
- Required fields
- Step count
- Empty content
- Safety classification
- Confidence
- Unexpected response sizes

Provide graceful fallback when structured output fails.

## Navigation

Use modern SwiftUI navigation.

Prefer `NavigationStack` and typed navigation where it improves clarity.

Navigation must be predictable.

Do not:
- Nest unnecessary navigation stacks
- Trigger navigation through fragile timing hacks
- Put business logic inside navigation destinations
- Lose user progress when navigating between guide steps
- Create different navigation conventions on every feature

The center Teach Me Left-Handed action can be visually distinctive, but it should still behave like a native iOS interaction.

## Sheets and Full-Screen Covers

Use sheets for contained tasks.

Use full-screen presentation only when the experience genuinely benefits from immersion, such as a dedicated camera flow.

Always provide a clear dismissal path.

Do not stack multiple sheets unnecessarily.

Avoid surprise modal presentation.

## Camera and Photos

Prefer native frameworks.

Use `PhotosPicker` for selecting existing images.

Only request camera permission when the user explicitly chooses to take a photo.

Explain permission requests in plain language.

Do not request photo-library access if `PhotosPicker` provides the needed functionality without broad access.

Do not ask users to photograph themselves.

Lefty should encourage photographing:
- Instructions
- Diagrams
- Books
- Worksheets
- Objects
- The work being learned

Do not retain original photos longer than needed unless the user explicitly saves something requiring them.

Handle:
- Permission denied
- Camera unavailable
- Cancelled capture
- Unsupported/corrupt image
- Large images
- Memory pressure

Resize/compress images appropriately before processing if full resolution is unnecessary.

## RevenueCat

RevenueCat is the subscription source of truth.

Use a clear entitlement such as:

`lefty_plus`

The UI should react to entitlement state rather than manually maintained premium booleans.

Support:
- Loading offerings
- Purchase
- Successful entitlement activation
- Cancelled purchase
- Failed purchase
- Restore Purchases
- Existing subscriber
- Expired entitlement
- Network failure

Never assume a purchase succeeded because the purchase sheet disappeared.

Never hardcode premium access just for the demo build.

Do not show the paywall on first launch.

Users should experience product value before encountering the primary paywall.

Keep purchase logic out of random individual views. Provide a small focused purchase/subscription service or observable model.

## Free Usage Limits

If Lefty has a free monthly conversion allowance, define one source of truth for:
- Allowance
- Usage
- Reset logic
- Premium bypass

Do not decrement usage for:
- Cancelled requests
- Failed processing
- Invalid input
- Requests where Lefty cannot generate a usable guide

Only count a conversion when a usable result is successfully delivered.

## Loading States

Every asynchronous action needs a deliberate loading state.

For Teach Me Left-Handed, use product language:

- Reading the instructions
- Finding what changes for a lefty
- Building your guide

Avoid:
- Blank screens
- Frozen buttons with no explanation
- Generic endless spinners
- Fake progress percentages unless progress is genuinely measurable

Prevent accidental duplicate submissions while processing.

## Error States

Design errors as part of the feature.

Every meaningful failure should answer:
1. What happened?
2. Can the user fix it?
3. What should they do next?

Examples:

**Can't read this clearly**
> Try taking another photo with the full instructions in frame.

**No connection**
> Teach Me Left-Handed needs a connection. Your saved guides are still available.

Preserve user input after recoverable errors.

Do not make users start over unnecessarily.

## Empty States

Empty states should teach the product.

Example for Saved Guides:

**Nothing saved yet**

> When Lefty teaches you something useful, save it here for next time.

Provide the relevant action when useful.

Do not fill empty states with decorative filler.

## Accessibility

Accessibility is not optional.

Every interactive control must have an appropriate accessible label.

Icon-only buttons require meaningful accessibility labels.

Support Dynamic Type.

Do not lock important text to tiny fixed sizes.

Touch targets should be at least 44×44 points.

Maintain sufficient contrast.

Do not communicate meaning through color alone.

Support VoiceOver ordering that matches the visual hierarchy.

Images that communicate instructions require useful accessibility descriptions.

Decorative images should not clutter VoiceOver.

Respect:
- Reduce Motion
- Increased contrast where applicable
- Dynamic Type
- VoiceOver

Test key flows with accessibility sizes before shipping.

Left-handedness does not justify placing every control on the left. Design for ergonomic use without creating a new accessibility problem.

## 13+ Audience

Lefty targets 13+ and is not an Apple Kids Category app.

Still design conservatively because teenagers may use it.

Do not collect information that is unnecessary.

Do not request:
- Full name
- Birthday
- School
- Address
- Precise location
- Contacts
- Profile photo
- Social accounts

No ads.

No manipulative purchase patterns.

Do not use shame, streak-loss threats, countdowns, fake scarcity, or aggressive upgrade language.

If a physical activity has meaningful safety risk, the product must respond appropriately.

## Privacy

Request the minimum permissions possible.

Every permission must correspond directly to a user action.

Do not request permissions speculatively during onboarding.

Good:
User taps Camera → request camera permission.

Bad:
First launch → request Camera + Photos + Notifications.

Store only what the product needs.

Do not log sensitive user-provided images or instruction content unnecessarily.

Never print secrets, purchase receipts, or full private user content to production logs.

## Notifications

Do not implement notifications unless there is a clear user benefit.

If implemented:
- Ask permission in context, not at first launch
- Explain why before the system prompt
- Respect denial
- Never repeatedly nag

Do not create notifications merely to increase engagement metrics.

## Design System

Use shared semantic design tokens.

At minimum define:
- Brand colors
- Background colors
- Surface/card colors
- Primary/secondary text
- Accent colors
- Spacing scale
- Corner radii
- Typography styles
- Standard card treatment
- Standard button treatment

Example concept:

```swift
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}
```

Do not scatter arbitrary values like:
`13`, `17`, `19`, `23`, `27`

through every screen without a design reason.

Approved mockups are the visual source of truth.

Do not silently redesign an approved screen while implementing it.

If an implementation limitation requires a design change, identify the conflict first.

## Components

Extract components when they create genuine consistency.

Likely shared components:
- Primary button
- Secondary button
- Category chip
- Guide card
- Tip card
- Progress indicator
- Section header
- Empty state
- Error state
- Loading state
- Premium badge

Do not create a generic mega-component with dozens of configuration parameters.

Prefer small semantic components.

## Typography

Use native/system typography unless the approved brand explicitly requires another font.

Use semantic hierarchy.

Do not choose font sizes independently on every screen.

Support Dynamic Type.

Avoid excessive font weights.

A screen should normally have one obvious primary heading.

## Dark Mode

If dark mode is supported, use semantic colors from the start.

Do not implement dark mode by scattering `colorScheme == .dark` checks throughout views.

Never simply invert colors.

Verify illustrations, cards, disabled states, separators, shadows, and text contrast in both modes.

If dark mode cannot be properly polished within the Shipaton timeframe, a polished light-only MVP is preferable to a broken dark mode, provided product requirements allow it.

## Haptics

Use haptics sparingly and meaningfully.

Good:
- Successful guide generation
- Completed practice interaction
- Important selection confirmation

Bad:
- Every tap
- Every scroll
- Decorative constant vibration

Respect system conventions.

## Animation

Animation should explain state change or add polish.

Use native SwiftUI animation.

Prefer subtle transitions.

Respect Reduce Motion.

Avoid:
- Long splash animations
- Excessive bouncing
- Animation that delays interaction
- Animating everything because SwiftUI makes it easy
- Heavy effects that hurt scrolling performance

The app should feel fast first, delightful second.

## Performance

Keep SwiftUI view bodies cheap.

Do not perform:
- Network requests
- Image processing
- Expensive filtering
- Database mutation
- Heavy computation

directly as uncontrolled side effects of `body`.

Use lazy containers for large scrolling collections.

Resize large images before repeatedly rendering them.

Avoid unnecessary observation that causes entire screens to refresh.

Use Instruments when there is an actual performance issue rather than guessing.

## Images

Use correct aspect ratios.

Avoid layout jumps while images load/process.

Provide placeholders where appropriate.

Do not stretch screenshots or instructional diagrams.

Instructional images should prioritize clarity over decoration.

## Forms and Input

Use native controls where practical.

Set correct keyboard/content types.

Provide keyboard dismissal behavior.

Do not hide important CTA buttons permanently behind the keyboard.

Validate input before starting expensive processing.

For pasted instructions, support multiline text naturally.

## Copy

Keep UI copy concise and human.

Prefer:
**Teach me left-handed**

over:
**Generate AI-powered left-handed instructions**

Prefer:
**I can't tell from this photo**

over:
**Image confidence threshold insufficient**

Do not expose implementation language to users:
- API
- model
- JSON
- endpoint
- inference
- prompt

unless it is genuinely relevant.

## Safety UX

Do not cover harmless skills in warnings.

For normal activities such as knitting, handwriting, crochet, or guitar, let the user learn.

For potentially dangerous activities, use proportional safety handling.

Never generate confident physical instructions when the system does not have enough information.

When uncertain, asking for another photo is a feature, not a failure.

## Testing

At minimum test the critical Shipaton path:

1. Fresh install
2. Onboarding
3. Home
4. Open Teach Me Left-Handed
5. Camera/photo input
6. Successful processing
7. Generated guide
8. Navigate every guide step
9. Save guide
10. Reopen saved guide
11. Reach free limit
12. Paywall
13. Successful sandbox purchase
14. Premium unlock
15. Restore purchase
16. App relaunch with entitlement retained

Also test:
- No network
- AI/service failure
- Invalid image
- User cancels camera
- User cancels purchase
- RevenueCat offerings fail to load
- Large Dynamic Type
- Dark mode if supported
- VoiceOver on critical controls
- App background/foreground during processing

## Unit Tests

Prioritize tests for logic where bugs would matter.

Examples:
- Free usage allowance
- Premium entitlement behavior
- Guide parsing/validation
- Safety-level mapping
- Persistence logic
- Progress calculation

Do not spend the two-week build writing tests for trivial static views.

## Preview Data

Every important SwiftUI screen should be easy to preview with realistic sample data.

Use representative left-handed content.

Do not require a live AI call or active RevenueCat connection just to render a SwiftUI preview.

Create mock/sample models for previews and development.

This makes UI iteration dramatically faster.

## Demo Reliability

The Shipaton demo is a product requirement.

The critical flow must be extremely reliable.

Before adding secondary features, ensure:

**Input → Teach Me Left-Handed → Generated Guide → Save → Paywall**

works consistently.

Handle network failure gracefully.

Have reviewed built-in/sample content available so the app still demonstrates its product quality outside the AI request.

Do not build a flashy secondary feature while the hero flow remains fragile.

## Code Quality

Code should be readable by another Swift developer without explanation.

Prefer explicit names.

Good:
`generateLeftHandedGuide(from:)`

Bad:
`processData()`

Keep functions focused.

Delete dead code.

Remove abandoned experiments before submission.

Do not leave:
- TODO placeholders in visible product flows
- Debug buttons
- Fake settings
- Lorem ipsum
- Console spam
- Commented-out blocks of old implementations
- Force unwraps where failure is realistically possible

## Git / Change Discipline

Make focused changes.

Do not refactor unrelated working code while implementing a feature.

Before a significant change:
1. Understand the existing implementation
2. Identify what actually needs changing
3. Preserve approved behavior/design
4. Make the smallest coherent change
5. Build/test it

Do not rewrite a working feature simply because another architecture is theoretically cleaner.

## Anti-Patterns — Do Not Do These

Do NOT:
- Convert the app to React Native
- Add a backend "for scalability"
- Add accounts
- Add community/social features
- Add Firebase/Supabase
- Add analytics SDKs without explicit approval
- Add packages for things Apple already handles well
- Create a chatbot interface
- Put API keys in source code
- Put networking directly in SwiftUI button closures across the app
- Create one giant global app state
- Create a view model for every tiny view
- Create protocols solely for architectural aesthetics
- Use force unwraps casually
- Ignore errors
- Use arbitrary delays to fix race conditions
- Trigger the same request repeatedly from `onAppear`
- Request permissions on launch
- Paywall the user before they understand Lefty
- Fake subscription state
- Blindly mirror left/right AI instructions
- Invent AI certainty
- Store photos unnecessarily
- Add features simply because they are technically interesting
- Redesign approved UI without being asked
- Sacrifice the hero experience to build more screens

## Decision Rule

When multiple implementation options are valid, choose the one that is:

1. Native
2. Simple
3. Reliable
4. Easy to understand
5. Easy to test
6. Accessible
7. Private
8. Fast enough to ship

For this project, clever architecture is not the goal.

**A beautifully executed, reliable Lefty app is the goal.**
