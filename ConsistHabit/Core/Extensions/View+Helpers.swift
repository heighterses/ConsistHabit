import SwiftUI

extension View {
    func respectReduceMotion(_ condition: Bool = UIAccessibility.isReduceMotionEnabled, spring: SwiftUI.Animation, fade: SwiftUI.Animation) -> SwiftUI.Animation {
        condition ? fade : spring
    }

    func withDefaultAnimation(_ animation: SwiftUI.Animation = AppTheme.Animation.springSnappy, _ action: @escaping () -> Void) {
        withAnimation(animation) {
            action()
        }
    }

    func applyThemeShadow(radius: CGFloat = 8, opacity: Double = 0.15) -> some View {
        shadow(color: Color.black.opacity(opacity), radius: radius, x: 0, y: 4)
    }

    func fillMaxWidth(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }

    func fillMaxHeight(alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }

    func fillMax(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    func shakeAnimation(_ trigger: Bool) -> some View {
        modifier(ShakeEffect(animatableData: trigger ? 1.0 : 0.0))
    }

    func pressableButton() -> some View {
        scaleEffect(1.0)
            .opacity(1.0)
    }

    func conditionalModifier<T: View>(_ condition: Bool, _ modifier: @escaping (Self) -> T) -> AnyView {
        if condition {
            return AnyView(modifier(self))
        } else {
            return AnyView(self)
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: Double

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = sin(animatableData * .pi * 4) * 5
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

extension View {
    func onAppearOnce(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppearOnceModifier(action: action))
    }
}

struct OnAppearOnceModifier: ViewModifier {
    let action: () -> Void
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            if !hasAppeared {
                hasAppeared = true
                action()
            }
        }
    }
}
