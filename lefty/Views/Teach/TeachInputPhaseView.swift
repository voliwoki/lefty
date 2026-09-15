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
                    Text("What do you want to learn?")
                        .font(AppFont.title)
                        .foregroundStyle(AppColors.primaryText)
                    Text("Take a photo, upload one, or just type it in.")
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            LeftyIconButton(systemImage: "xmark.circle.fill", accessibilityLabel: "Remove photo") {
                                self.selectedImage = nil
                            }
                            .padding(4)
                        }
                }

                HStack(spacing: AppSpacing.md) {
                    Button {
                        isShowingCamera = true
                    } label: {
                        inputOptionLabel(icon: "camera.fill", title: "Camera")
                    }
                    .buttonStyle(.plain)

                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        inputOptionLabel(icon: "photo.on.rectangle", title: "Upload")
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Or type it in")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.primaryText)
                    TextEditor(text: $typedText)
                        .font(AppFont.body)
                        .frame(minHeight: 100)
                        .padding(AppSpacing.sm)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: "Teach me left-handed",
                primaryIcon: "hand.point.up.left.fill",
                isPrimaryEnabled: canGenerate,
                primaryAction: onGenerate
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraPicker { image in
                selectedImage = image
            }
            .ignoresSafeArea()
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

    private func inputOptionLabel(icon: String, title: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(title)
                .font(AppFont.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .foregroundStyle(AppColors.primaryText)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }
}
