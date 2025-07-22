import SwiftUI

struct LeaderboardView: View {
    @State private var girls: [Girl] = []
    @State private var isLoading = true

    private let firebaseService = FirebaseGirlService()

    var onBack: () -> Void = {}

    // Define your primary colors and gradient here for consistency
    let primaryColors = [
        Color(#colorLiteral(red: 0.239, green: 0.674, blue: 0.969, alpha: 1)),
        Color(#colorLiteral(red: 0.259, green: 0.757, blue: 0.969, alpha: 1))
    ]
    var primaryGradient: LinearGradient {
        LinearGradient(colors: primaryColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Rang lista")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(primaryColors.first ?? .purple)
                .padding(.bottom)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColors.first ?? .purple))
            } else {
                List(girls.prefix(5)) { girl in
                    HStack {
                        Text(girl.name)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("\(girl.wins)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }

            ModernButton(
                label: "Nazad na početni ekran",
                gradient: primaryGradient,
                shadowColor: primaryColors.first ?? .purple,
                action: onBack
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .onAppear {
            loadLeaderboard()
        }
    }

    func loadLeaderboard() {
        firebaseService.fetchGirls { fetchedGirls in
            DispatchQueue.main.async {
                self.girls = fetchedGirls.sorted { $0.wins > $1.wins }
                self.isLoading = false
            }
        }
    }
}
