import SwiftUI

struct HomeView: View {
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
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header
                funFactCard
                famousLeftyCard
            }
            .padding(AppSpacing.lg)
            .frame(maxHeight: .infinity)
            .background(AppColors.background)
            .toolbar(.hidden)
        }
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "hand.wave.fill")
                .scaleEffect(x: -1, y: 1)
                .foregroundStyle(AppColors.brandPurple)
                .accessibilityHidden(true)
            Text("Lefty")
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
        ScrollView {
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
                        Text("\(famousLefty.field) · b. \(famousLefty.bornYear)")
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

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .leftyCard()
    }
}

#Preview {
    HomeView()
}
