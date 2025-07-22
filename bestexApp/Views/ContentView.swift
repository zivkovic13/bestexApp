import SwiftUI
import SwiftData

struct ContentView: View {
    enum Screen {
        case home, tournament, leaderboard, pravilnik
    }

    @State private var currentScreen: Screen = .home

    @Environment(\.modelContext) private var context
    @Query private var localGirls: [Girl]  // load SwiftData girls

    var body: some View {
        switch currentScreen {
        case .home:
            HomeView(
                startAction: {
                    withAnimation { currentScreen = .tournament }
                },
                leaderboardAction: {
                    withAnimation { currentScreen = .leaderboard }
                },
                pravilnikAction: {
                    withAnimation { currentScreen = .pravilnik }
                }
            )
            .onAppear {
                if localGirls.isEmpty {
                    loadGirlsFromFirebase()
                }
            }

        case .tournament:
            TournamentView(onExit: {
                withAnimation { currentScreen = .home }
            })

        case .leaderboard:
            LeaderboardView(onBack: {
                withAnimation { currentScreen = .home }
            })
            
        case .pravilnik:
            PravilnikView(onBack: {
                withAnimation { currentScreen = .home }
            })
        }
    }

    private func loadGirlsFromFirebase() {
        FirebaseGirlService().fetchGirls { girls in
            DispatchQueue.main.async {
                for girl in girls {
                    context.insert(girl)
                }
                try? context.save()
            }
        }
    }
}
