import SwiftUI

struct ContentView: View {
    enum Screen {
        case home, tournament, leaderboard
    }

    @State private var currentScreen: Screen = .home

    var body: some View {
        switch currentScreen {
        case .home:
            HomeView(
                startAction: {
                    withAnimation { currentScreen = .tournament }
                },
                leaderboardAction: {
                    withAnimation { currentScreen = .leaderboard }
                }
            )
        case .tournament:
            TournamentView(onExit: {
                withAnimation { currentScreen = .home }
            })
        case .leaderboard:
            LeaderboardView(onBack: {
                withAnimation { currentScreen = .home }
            })
        }
    }
}
