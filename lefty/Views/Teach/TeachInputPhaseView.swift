import SwiftUI
import PhotosUI

struct TeachInputPhaseView: View {
    @Binding var selectedImage: UIImage?
    @Binding var typedText: String
    let onGenerate: () -> Void

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isShowingCamera = false

    private var canGenerate: Bool {
        selectedImage != nil || !typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                }

                inputOptionsRow

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(String(localized: "Or type it in"))
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.primaryText)
                    TextEditor(text: $typedText)
                        .font(AppFont.body)
                        .frame(minHeight: 100)
                        .padding(AppSpacing.sm)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        .accessibilityLabel(String(localized: "Describe what you want to learn"))
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: String(localized: "Teach me left-handed"),
                primaryIcon: "hand.point.up.left.fill",
                isPrimaryEnabled: canGenerate,
                primaryAction: onGenerate
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            TeachCaptureView { image in
                selectedImage = image
            }
        }
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
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
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Camera"))
            .accessibilityHint(String(localized: "Photograph instructions or a diagram"))

            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                uploadCard
            }
            .buttonStyle(.plain)
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
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.accent, lineWidth: 2)
        )
        .shadow(color: AppColors.accent.opacity(0.18), radius: 8, x: 0, y: 4)
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
}
