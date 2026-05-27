import SwiftUI
import StoreKit
import SwiftData

struct PremiumUpgradeSheet: View {
    @Environment(HabitStore.self) var store
    @Binding var isPresented: Bool
    @State private var products: [Product] = []
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var isAnnual = true
    @State private var purchaseError: String?
    @Environment(\.dismiss) var dismiss

    let productIDs = ["com.consisthabit.premium.monthly", "com.consisthabit.premium.annual"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxxl) {
                        heroSection

                        if let session = store.userSession {
                            streakRewardSection(session)
                        }

                        featuresSection

                        planToggleAndPricing
                    }
                    .padding(AppTheme.Spacing.lg)
                }

                VStack(spacing: AppTheme.Spacing.md) {
                    if let error = purchaseError {
                        Text(error)
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.AccentColor.coral)
                            .fillMaxWidth()
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.AccentColor.coral.opacity(0.1))
                            .cornerRadius(AppTheme.Radius.md)
                    }

                    Button {
                        purchasePremium()
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Subscribe Now")
                                .font(AppTheme.Typography.headingMedium)
                        }
                    }
                    .fillMaxWidth()
                    .frame(height: 56)
                    .background(AppTheme.AccentColor.gold)
                    .foregroundColor(.black)
                    .cornerRadius(AppTheme.Radius.lg)
                    .disabled(isPurchasing || selectedProduct == nil)
                    .opacity(isPurchasing || selectedProduct == nil ? 0.5 : 1.0)

                    Button {
                        dismiss()
                    } label: {
                        Text("Not Now")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.TextColor.secondary)
                            .fillMaxWidth()
                            .frame(height: 48)
                    }

                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text("Cancel anytime before renewal")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.TextColor.tertiary)

                        HStack(spacing: AppTheme.Spacing.sm) {
                            Link("Privacy Policy", destination: URL(string: "https://example.com/privacy") ?? URL(fileURLWithPath: ""))
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.AccentColor.mint)

                            Text("•")
                                .foregroundColor(AppTheme.TextColor.tertiary)

                            Link("Terms", destination: URL(string: "https://example.com/terms") ?? URL(fileURLWithPath: ""))
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.AccentColor.mint)
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.BackgroundColor.elevated)
            }
            .background(AppTheme.BackgroundColor.primary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.TextColor.secondary)
                }
            }
        }
        .task {
            await loadProducts()
        }
    }

    private var heroSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(AppTheme.AccentColor.gold.opacity(0.2))
                    .frame(width: 100, height: 100)

                Text("⭐")
                    .font(.system(size: 48))
                    .scaleEffect(1.0)
                    .animation(
                        AppTheme.Animation.springBouncy.repeatForever(autoreverses: true),
                        value: true
                    )
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Go Premium")
                    .font(AppTheme.Typography.headingLarge)
                    .foregroundColor(AppTheme.AccentColor.gold)

                Text("Unlock unlimited habits and advanced features")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func streakRewardSection(_ session: UserSession) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Your Streak Rewards")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)
                .fillMaxWidth(alignment: .leading)

            VStack(spacing: AppTheme.Spacing.md) {
                streakRewardRow(
                    icon: "🔥",
                    milestone: "14-day Streak",
                    status: session.streakRewardSlots >= 1,
                    progress: min(Double(session.currentStreak) / 14.0, 1.0)
                )

                streakRewardRow(
                    icon: "👑",
                    milestone: "30-day Streak",
                    status: session.streakRewardSlots >= 2,
                    progress: min(Double(session.currentStreak) / 30.0, 1.0)
                )
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func streakRewardRow(icon: String, milestone: String, status: Bool, progress: Double) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(icon)
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(milestone)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.primary)

                ProgressView(value: progress)
                    .tint(AppTheme.AccentColor.mint)
            }

            Spacer()

            if status {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.AccentColor.mint)
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Premium Features")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            VStack(spacing: AppTheme.Spacing.md) {
                featureRow(icon: "♾️", text: "Unlimited Habits")
                featureRow(icon: "📊", text: "Advanced Analytics")
                featureRow(icon: "🔔", text: "Smart Reminders")
                featureRow(icon: "☁️", text: "iCloud Sync")
                featureRow(icon: "🎨", text: "Custom Themes")
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(icon)
                .font(.system(size: 20))

            Text(text)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            Spacer()
        }
    }

    private var planToggleAndPricing: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Picker("Plan", selection: $isAnnual) {
                Text("Monthly").tag(false)
                Text("Annual (Best Value)").tag(true)
            }
            .pickerStyle(.segmented)
            .tint(AppTheme.AccentColor.mint)

            if let monthly = products.first(where: { $0.id == "com.consisthabit.premium.monthly" }),
               let annual = products.first(where: { $0.id == "com.consisthabit.premium.annual" }) {
                let displayProduct = isAnnual ? annual : monthly
                let displayPrice = displayProduct.displayPrice

                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(isAnnual ? "Annual" : "Monthly")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.TextColor.secondary)

                        if isAnnual, let monthlyPrice = products.first(where: { $0.id == "com.consisthabit.premium.monthly" })?.displayPrice {
                            let annualTotal = displayPrice
                            let monthlyEquivalent = "\(monthlyPrice)/month"
                            Text(monthlyEquivalent)
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.TextColor.tertiary)
                        }
                    }

                    Spacer()

                    Text(displayPrice)
                        .font(AppTheme.Typography.numeric)
                        .foregroundColor(AppTheme.AccentColor.gold)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.BackgroundColor.elevated)
                .cornerRadius(AppTheme.Radius.lg)
            }
        }
    }

    private func loadProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: Set(productIDs))
            products = fetchedProducts.sorted { $0.id < $1.id }
            selectedProduct = products.first(where: { $0.id == "com.consisthabit.premium.annual" })
        } catch {
            purchaseError = "Could not load products"
        }
    }

    private func purchasePremium() {
        guard let product = selectedProduct else { return }
        isPurchasing = true

        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    do {
                        let transaction = try verification.payloadValue
                        await transaction.finish()
                        store.updatePremiumStatus(true)
                        HapticManager.shared.trigger(.achievementUnlock)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    } catch {
                        isPurchasing = false
                        purchaseError = "Transaction verification failed"
                    }

                case .pending:
                    isPurchasing = false
                    purchaseError = nil

                case .userCancelled:
                    isPurchasing = false
                    purchaseError = nil

                @unknown default:
                    isPurchasing = false
                    purchaseError = "Unknown error occurred"
                }
            } catch {
                isPurchasing = false
                purchaseError = error.localizedDescription
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true

    return PremiumUpgradeSheet(isPresented: $isPresented)
        .modelContainer(for: UserSession.self, inMemory: true)
}
