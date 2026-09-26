import SwiftUI
import PhotosUI

struct TeachInputPhaseView: View {
    @Binding var selectedImage: UIImage?
    @Binding var typedText: String
    let onGenerate: () -> Void
    var autoOpenCamera: Bool = false
    var autoFocusText: Bool = false

    @Environment(SubscriptionService.self) private var subscription
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isShowingCamera = false
    @State private var hasAutoOpenedCamera = false
    @State private var hasAutoFocusedText = false
    @State private var isPaywallPresented = false
    @FocusState private var isTextFieldFocused: Bool

    private static let quickStartExamples = ["Tie a tie", "Use scissors", "Chopsticks"]

    private var canGenerate: Bool {
        selectedImage != nil || !typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var usageStatusText: String {
        TeachUsageStore.statusText(isLeftyPlusActive: subscription.isLeftyPlusActive)
    }

    private var textSectionTitle: String {
        selectedImage != nil
            ? String(localized: "Add more detail (optional)")
            : String(localized: "Or type it in")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(String(localized: "What do you want to learn?"))
                        .font(AppFont.title)
                        .foregroundStyle(AppColors.primaryText)
                    Text(String(localized: "Take a photo, upload one, or just type it in."))
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                if let selectedImage {
                    selectedPhotoCard(selectedImage)
                } else {
                    inputOptionsRow
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(textSectionTitle)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.primaryText)
                    if selectedImage != nil {
                        Text(String(localized: "Anything the photo doesn't show — like what you're trying to do, or a question about it."))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    ZStack(alignment: .topLeading) {
                        if typedText.isEmpty {
                            Text(String(localized: "e.g. how to tie a tie"))
                                .font(AppFont.body)
                                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
                                .padding(.horizontal, AppSpacing.sm + 4)
                                .padding(.vertical, AppSpacing.sm + 8)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $typedText)
                            .font(AppFont.body)
                            .frame(minHeight: 100)
                            .padding(AppSpacing.sm)
                            .scrollContentBackground(.hidden)
                            .focused($isTextFieldFocused)
                    }
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                    .accessibilityLabel(String(localized: "Describe what you want to learn"))

                    if selectedImage == nil {
                        quickStartRow
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: AppSpacing.sm) {
                usageRow

                LeftyActionBar(
                    primaryTitle: String(localized: "Teach me left-handed"),
                    primaryIcon: "hand.point.up.left.fill",
                    isPrimaryEnabled: canGenerate,
                    primaryAction: onGenerate
                )
            }
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            TeachCaptureView { image in
                selectedImage = image
            }
        }
        .sheet(isPresented: $isPaywallPresented) {
            PaywallSheet()
        }
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
        .onAppear {
            if autoOpenCamera, !hasAutoOpenedCamera {
                hasAutoOpenedCamera = true
                isShowingCamera = true
            }
        }
        .task {
            guard autoFocusText, !hasAutoFocusedText else { return }
            hasAutoFocusedText = true
            try? await Task.sleep(for: .seconds(0.35))
            isTextFieldFocused = true
        }
    }

    private var usageRow: some View {
        HStack(spacing: AppSpacing.xs) {
            Text(usageStatusText)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)

            if !subscription.isLeftyPlusActive {
                Text("·")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Button {
                    isPaywallPresented = true
                } label: {
                    Text(String(localized: "Go unlimited"))
                        .font(AppFont.captionEmphasized)
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.pressScale)
            }
        }
    }

    private var quickStartRow: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(String(localized: "Try:"))
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)
            ForEach(Self.quickStartExamples, id: \.self) { example in
                Button {
                    typedText = example
                } label: {
                    LeftyChip(title: example, tone: .purple)
                }
                .buttonStyle(.pressScale)
            }
        }
    }

    private var inputOptionsRow: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Button {
                isShowingCamera = true
            } label: {
                cameraHeroCard
            }
            .buttonStyle(.pressScale)
            .accessibilityLabel(String(localized: "Camera"))
            .accessibilityHint(String(localized: "Photograph instructions or a diagram"))

            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                uploadCard
            }
            .buttonStyle(.pressScale)
            .accessibilityLabel(String(localized: "Upload"))
            .accessibilityHint(String(localized: "Choose a photo from your library"))
        }
    }

    private var cameraHeroCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            LeftyIconBadge(systemImage: "camera.fill", tone: .pink)
            Text(String(localized: "Camera"))
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            Text(String(localized: "Snap instructions"))
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private var uploadCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            LeftyIconBadge(systemImage: "photo.on.rectangle", tone: .purple)
            Text(String(localized: "Upload"))
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            Text(String(localized: "From Photos"))
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private func selectedPhotoCard(_ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 240)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

            HStack(spacing: AppSpacing.sm) {
                Button {
                    isShowingCamera = true
                } label: {
                    Label(String(localized: "Retake"), systemImage: "camera.fill")
                        .font(AppFont.subheadlineEmphasized)
                        .frame(minHeight: 44)
                        .padding(.horizontal, AppSpacing.md)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)

                Button(role: .destructive) {
                    selectedImage = nil
                } label: {
                    Label(String(localized: "Remove"), systemImage: "trash")
                        .font(AppFont.subheadline)
                        .frame(minHeight: 44)
                        .padding(.horizontal, AppSpacing.md)
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 0)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(AppColors.accent.opacity(0.55), lineWidth: 1.5)
        )
        .shadow(color: AppColors.brandPurple.opacity(0.12), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    TeachInputPhaseView(
        selectedImage: .constant(nil),
        typedText: .constant(""),
        onGenerate: {}
    )
    .environment(SubscriptionService())
}
