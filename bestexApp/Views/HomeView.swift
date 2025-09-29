import SwiftUI

struct HomeView: View {
    var startAction: () -> Void
    var leaderboardAction: () -> Void
    var pravilnikAction: () -> Void

    @State private var animateButtons = false

    // Define colors separately
    let primaryColors = [Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))]
    let exitColors = [Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)), Color(#colorLiteral(red: 0.9358596206, green: 0, blue: 0, alpha: 1))]

    var body: some View {
        let primaryGradient = LinearGradient(colors: primaryColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        let exitGradient = LinearGradient(colors: exitColors, startPoint: .topLeading, endPoint: .bottomTrailing)

        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    Text("Dobrodošli u izbor za\nMISS Živković")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(primaryGradient)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 2, y: 2)
                        .padding(.horizontal, 40)

                    Text("Pripremite se za odabir najlepše devojke u konkurenciji od 220+ takmičarki 💃\nPre početka igre pročitaj pravilnik 📖")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)

                    Spacer()

                    VStack(spacing: 22) {
                        ModernButton(
                            label: "🚀 Pokreni takmičenje",
                            gradient: primaryGradient,
                            shadowColor: primaryColors.first ?? .purple,
                            action: startAction
                        )
                        ModernButton(
                            label: "🏆 Rang lista",
                            gradient: primaryGradient,
                            shadowColor: primaryColors.first ?? .purple,
                            action: leaderboardAction
                        )
                        ModernButton(
                            label: "📜 Pravilnik",
                            gradient: primaryGradient,
                            shadowColor: primaryColors.first ?? .purple,
                            action: pravilnikAction
                        )
                        ModernButton(
                            label: "IZLAZ",
                            gradient: exitGradient,
                            shadowColor: exitColors.first ?? .red,
                            action: { exit(0) }
                        )
                    }
                    .padding(.horizontal, 40)
                    .scaleEffect(animateButtons ? 1 : 0.95)
                    .opacity(animateButtons ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: animateButtons)

                    Spacer(minLength: 40)
                }
            }
            .onAppear {
                animateButtons = true
            }
        }
    }
}
