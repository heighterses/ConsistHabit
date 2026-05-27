import SwiftUI
import UIKit

enum AppTheme {
    // MARK: - Background Colors (Light Premium Theme)
    enum BackgroundColor {
        static let primary = Color(red: 0.97, green: 0.97, blue: 0.96)      // #F8F8F6
        static let secondary = Color(red: 0.95, green: 0.95, blue: 0.94)    // #F3F3F0
        static let elevated = Color(red: 1.0, green: 1.0, blue: 1.0)        // #FFFFFF
        static let card = Color(red: 1.0, green: 1.0, blue: 1.0)            // #FFFFFF
    }

    // MARK: - Accent Colors
    enum AccentColor {
        static let mint = Color(red: 0.55, green: 0.87, blue: 0.87)       // #8BDFDD
        static let coral = Color(red: 0.96, green: 0.56, blue: 0.41)      // #F48F68
        static let gold = Color(red: 1.0, green: 0.89, blue: 0.58)        // #FFE394
    }

    // MARK: - Text Colors (Light Premium Theme)
    enum TextColor {
        static let primary = Color(red: 0.11, green: 0.11, blue: 0.12)      // #1C1C1E - Deep charcoal
        static let secondary = Color(red: 0.56, green: 0.56, blue: 0.58)    // #8E8E93
        static let tertiary = Color(red: 0.75, green: 0.75, blue: 0.76)     // #BFBFC0
        static let disabled = Color(red: 0.85, green: 0.85, blue: 0.86)     // #D9D9DC
    }

    // MARK: - Typography
    enum Typography {
        static let displayLarge = Font.system(size: 38, weight: .black, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .black, design: .rounded)
        static let headingLarge = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headingMedium = Font.system(size: 17, weight: .bold, design: .rounded)
        static let bodyLarge = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .rounded)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .rounded)
        static let labelSmall = Font.system(size: 10, weight: .semibold, design: .rounded)
        static let numeric = Font.system(size: 24, weight: .black, design: .rounded)
    }

    // MARK: - Spacing Scale (8pt base grid)
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Corner Radius
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }

    // MARK: - Animations
    enum Animation {
        static let springSnappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.5)
        static let springSmooth = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let easeDefault = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let matrixTransition = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.75)
    }

    // MARK: - Matrix Constants
    enum Matrix {
        static let weekCount = 26
        static let tileSize: CGFloat = 11
        static let tileSpacing: CGFloat = 3
        static let cornerRadius: CGFloat = 2.5
        static let emptyTileColor = Color(red: 0.92, green: 0.92, blue: 0.92)  // #EAEAEA

        static func opacityForRatio(_ ratio: Double) -> Double {
            switch ratio {
            case 0:
                return 0.07
            case 0.001...0.25:
                return 0.22
            case 0.251...0.50:
                return 0.44
            case 0.501...0.75:
                return 0.66
            case 0.751..<1.0:
                return 0.85
            case 1.0:
                return 1.0
            default:
                return 0.07
            }
        }
    }

    // MARK: - Business Logic Constants
    enum Business {
        static let baseFreeHabits = 3
        static let maxFreeHabitsAfter14Days = 4
        static let maxFreeHabitsAfter30Days = 6

        static let streakFor14DayReward = 14
        static let streakFor30DayReward = 30

        static let photoCompressionQuality: CGFloat = 0.8
        static let photoThumbnailSize: CGFloat = 200
    }

    // MARK: - Haptic Events
    enum Haptic {
        static let habitComplete = "habitComplete"
        static let habitUncomplete = "habitUncomplete"
        static let achievementUnlock = "achievementUnlock"
        static let buttonTap = "buttonTap"
        static let selectionChange = "selectionChange"
    }
}

// MARK: - Helper Extension for Light/Dark Variants
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
