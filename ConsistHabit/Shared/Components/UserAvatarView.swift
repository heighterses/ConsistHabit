import SwiftUI

struct UserAvatarView: View {
    let session: UserSession
    let size: CGFloat

    var body: some View {
        Group {
            if session.hasCustomPhoto, let imageData = session.avatarImageData {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    placeholderAvatar
                }
            } else {
                Text(session.avatarIdentifier)
                    .font(.system(size: size * 0.4, weight: .semibold, design: .default))
                    .frame(width: size, height: size)
                    .background(Circle().fill(AppTheme.BackgroundColor.elevated))
            }
        }
    }

    private var placeholderAvatar: some View {
        Circle()
            .fill(AppTheme.BackgroundColor.elevated)
            .frame(width: size, height: size)
            .overlay(
                Text("?")
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(AppTheme.TextColor.tertiary)
            )
    }
}

#Preview {
    let session = UserSession(
        username: "John Doe",
        avatarIdentifier: "🎯"
    )

    UserAvatarView(session: session, size: 64)
        .padding()
        .background(AppTheme.BackgroundColor.primary)
}
