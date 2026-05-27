import SwiftUI
import Combine

struct AchievementCelebrationView: View {
    let achievement: Achievement
    @State private var isAnimating = false
    @State private var confetti: [ConfettiPiece] = []
    @Environment(HabitStore.self) var store

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    store.celebrationAchievement = nil
                }

            Canvas { context, size in
                for piece in confetti {
                    var transform = CGAffineTransform(translationX: piece.x, y: piece.y)
                    transform = transform.rotated(by: piece.rotation)

                    var contextCopy = context
                    contextCopy.opacity = Double(1.0 - (piece.lifetime / 3.0))

                    let rect = CGRect(x: 0, y: 0, width: 8, height: 8)
                    let path = RoundedRectangle(cornerRadius: 2)
                    contextCopy.fill(
                        path.path(in: rect),
                        with: .color(piece.color)
                    )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()

                VStack(spacing: AppTheme.Spacing.md) {
                    Text(achievement.type.icon)
                        .font(.system(size: 72))
                        .scaleEffect(isAnimating ? 1.1 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                        .animation(
                            AppTheme.Animation.springBouncy.repeatCount(2),
                            value: isAnimating
                        )

                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Achievement Unlocked!")
                            .font(AppTheme.Typography.headingLarge)
                            .foregroundColor(AppTheme.AccentColor.gold)

                        Text(achievement.type.title)
                            .font(AppTheme.Typography.headingMedium)
                            .foregroundColor(AppTheme.TextColor.primary)

                        Text(achievement.type.description)
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.TextColor.secondary)
                            .multilineTextAlignment(.center)

                        if let rewardMessage = achievement.type.rewardMessage {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Divider()
                                    .padding(.vertical, AppTheme.Spacing.md)

                                Text(rewardMessage)
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundColor(AppTheme.AccentColor.gold)
                                    .multilineTextAlignment(.center)
                                    .padding(AppTheme.Spacing.md)
                                    .background(AppTheme.AccentColor.gold.opacity(0.1))
                                    .cornerRadius(AppTheme.Radius.lg)
                            }
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.BackgroundColor.elevated)
                .cornerRadius(AppTheme.Radius.xl)
                .applyThemeShadow(radius: 20, opacity: 0.4)

                Spacer()

                Button {
                    store.celebrationAchievement = nil
                } label: {
                    Text("Nice!")
                        .font(AppTheme.Typography.headingMedium)
                        .fillMaxWidth()
                        .frame(height: 56)
                        .background(AppTheme.AccentColor.mint)
                        .foregroundColor(.black)
                        .cornerRadius(AppTheme.Radius.lg)
                }
                .padding(AppTheme.Spacing.lg)
            }
        }
        .onAppear {
            isAnimating = true
            generateConfetti()
            animateConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                store.celebrationAchievement = nil
            }
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [
            AppTheme.AccentColor.mint,
            AppTheme.AccentColor.coral,
            AppTheme.AccentColor.gold,
            .white
        ]

        for _ in 0..<50 {
            let x = CGFloat.random(in: -100...100)
            let y = CGFloat.random(in: -300...0)
            let rotation = CGFloat.random(in: 0...(2 * .pi))
            let color = colors.randomElement() ?? AppTheme.AccentColor.mint
            let velocityX = CGFloat.random(in: -100...100)
            let velocityY = CGFloat.random(in: 100...300)

            confetti.append(ConfettiPiece(
                x: x,
                y: y,
                rotation: rotation,
                color: color,
                velocityX: velocityX,
                velocityY: velocityY,
                lifetime: 3.0
            ))
        }
    }

    private func animateConfetti() {
        let displayLink = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
        var subscription: AnyCancellable?

        subscription = displayLink.sink { _ in
            withAnimation(.linear(duration: 0.016)) {
                for i in 0..<confetti.count {
                    confetti[i].x += confetti[i].velocityX * 0.016
                    confetti[i].y += confetti[i].velocityY * 0.016
                    confetti[i].rotation += 0.05
                    confetti[i].lifetime -= 0.016
                    confetti[i].velocityY += 100 * 0.016
                }

                confetti.removeAll { $0.lifetime <= 0 }

                if confetti.isEmpty {
                    subscription?.cancel()
                }
            }
        }
    }
}

struct ConfettiPiece {
    var x: CGFloat
    var y: CGFloat
    var rotation: CGFloat
    let color: Color
    var velocityX: CGFloat
    var velocityY: CGFloat
    var lifetime: Double
}

#Preview {
    let achievement = Achievement(type: .streak14Days)

    AchievementCelebrationView(achievement: achievement)
        .background(AppTheme.BackgroundColor.primary)
}
