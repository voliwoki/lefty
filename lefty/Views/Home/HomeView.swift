import SwiftUI

struct HomeView: View {
    @Environment(SubscriptionService.self) private var subscription
    @State private var isTeachPresented = false
    @State private var teachStartsWithCamera = false

    private var fact: String {
        let index = DailyContent.todayIndex(poolSize: FunFactPool.facts.count)
        return FunFactPool.facts[index]
    }

    private var famousLefty: FamousLefty {
        let index = DailyContent.todayIndex(poolSize: FamousLeftyPool.people.count)
        return FamousLeftyPool.people[index]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    teachHeroCard

                    Text("TODAY")
                        .font(AppFont.captionEmphasized)
                        .tracking(1)
                        .foregroundStyle(AppColors.secondaryText)

                    funFactCard
                    famousLeftyCard
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .toolbar(.hidden)
            .sheet(isPresented: $isTeachPresented) {
                TeachFlowView(startWithCamera: teachStartsWithCamera, startFocused: !teachStartsWithCamera)
            }
        }
    }

    private var teachHeroCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("TEACH ME LEFT-HANDED")
                .font(AppFont.captionEmphasized)
                .tracking(1)
                .foregroundStyle(.white.opacity(0.85))

            Text("Got right-handed instructions? We'll flip them.")
                .font(AppFont.title)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            teachInputShortcut

            Text(TeachUsageStore.statusText(isLeftyPlusActive: subscription.isLeftyPlusActive))
                .font(AppFont.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(AppColors.accent)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 40, y: -50)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private var teachInputShortcut: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("What do you want to learn?")
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)

            Spacer(minLength: AppSpacing.sm)

            Button {
                teachStartsWithCamera = true
                isTeachPresented = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(AppColors.primaryText)
                    .clipShape(Circle())
            }
            .buttonStyle(.pressScale)
            .accessibilityLabel(String(localized: "Open camera"))
        }
        .padding(.leading, AppSpacing.lg)
        .padding(.trailing, AppSpacing.xs + 2)
        .frame(height: 52)
        .background(.white)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            teachStartsWithCamera = false
            isTeachPresented = true
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(String(localized: "What do you want to learn? Opens Teach"))
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            HandDrawnHandIcon(size: 28)
            Text("lefty")
                .font(AppFont.logo(size: 36))
                .foregroundStyle(AppColors.brandPurple)
                .leftLean()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Lefty")
    }

    private var funFactCard: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            LeftyIconBadge(systemImage: "lightbulb.fill", tone: .yellow)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Fun Fact of the Day")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text(fact)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .leftyCard()
    }

    private var famousLeftyCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Famous Lefty of the Day")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)

            HStack(spacing: AppSpacing.md) {
                LeftyIconBadge(systemImage: famousLefty.icon, tone: .purple, size: 56)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(famousLefty.name)
                        .font(AppFont.title)
                        .foregroundStyle(AppColors.primaryText)
                    Text("\(famousLefty.field) · b. \(String(famousLefty.bornYear))")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }

            Text(famousLefty.blurb)
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Did you know?")
                    .font(AppFont.subheadlineEmphasized)
                    .foregroundStyle(AppColors.primaryText)
                Text(famousLefty.didYouKnow)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.chipPurpleBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .leftyCard()
    }
}

#Preview {
    HomeView()
        .environment(SubscriptionService())
}
