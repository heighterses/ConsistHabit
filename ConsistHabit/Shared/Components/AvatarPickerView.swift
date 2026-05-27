import SwiftUI
import PhotosUI

struct AvatarPickerView: View {
    @Binding var selectedEmojiAvatar: String
    @Binding var selectedPhotoData: Data?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var tempImage: UIImage?

    let emojiAvatars = [
        "🎯", "🚀", "⭐", "💡", "🎨", "🏆", "💪", "🔥",
        "🌟", "✨", "🎪", "🎭", "🎬", "🎸", "📚", "⚡"
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Photo")
                    .font(AppTheme.Typography.headingMedium)
                    .foregroundColor(AppTheme.TextColor.primary)
                    .fillMaxWidth(alignment: .leading)

                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        if let image = tempImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.AccentColor.mint)
                        }

                        Text(tempImage != nil ? "Change Photo" : "Upload Photo")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.AccentColor.mint)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(AppTheme.BackgroundColor.elevated)
                    .cornerRadius(AppTheme.Radius.lg)
                }
                .onChange(of: photoPickerItem) { _, newItem in
                    Task {
                        guard let newItem = newItem else { return }

                        do {
                            if let data = try await newItem.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    let compressed = await compressImage(image)
                                    await MainActor.run {
                                        tempImage = compressed
                                        selectedPhotoData = compressed.jpegData(compressionQuality: AppTheme.Business.photoCompressionQuality)
                                        selectedEmojiAvatar = ""
                                    }
                                }
                            }
                        } catch {
                            print("Failed to load photo: \(error)")
                        }
                    }
                }
            }

            VStack(spacing: AppTheme.Spacing.md) {
                Text("Or Choose Emoji")
                    .font(AppTheme.Typography.headingMedium)
                    .foregroundColor(AppTheme.TextColor.primary)
                    .fillMaxWidth(alignment: .leading)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: AppTheme.Spacing.md) {
                    ForEach(emojiAvatars, id: \.self) { emoji in
                        Button {
                            withAnimation(AppTheme.Animation.springSnappy) {
                                selectedEmojiAvatar = emoji
                                tempImage = nil
                                selectedPhotoData = nil
                            }
                            HapticManager.shared.trigger(.selectionChange)
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(selectedEmojiAvatar == emoji ? AppTheme.AccentColor.mint : AppTheme.BackgroundColor.elevated)
                                .cornerRadius(AppTheme.Radius.md)
                                .scaleEffect(selectedEmojiAvatar == emoji ? 1.05 : 1.0)
                        }
                    }
                }
            }
        }
    }

    private func compressImage(_ image: UIImage) async -> UIImage {
        let size = AppTheme.Business.photoThumbnailSize
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        image.draw(in: rect)
        let compressed = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return compressed
    }
}

#Preview {
    @Previewable @State var selectedEmoji = ""
    @Previewable @State var selectedPhoto: Data?

    return VStack {
        AvatarPickerView(selectedEmojiAvatar: $selectedEmoji, selectedPhotoData: $selectedPhoto)
            .padding()
    }
    .background(AppTheme.BackgroundColor.primary)
}
