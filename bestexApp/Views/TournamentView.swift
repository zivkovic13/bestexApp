import SwiftUI

struct TournamentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var girls: [Girl] = []
    @State private var roundType: RoundType = .qualifying
    @State private var currentMatchIndex = 0
    @State private var winners: [Girl] = []
    @State private var remainingGirls: Int = 0
    @State private var isLoading = true
    @State private var showNextRoundButton = false
    @State private var luckyLosers: [Girl] = []
    @State private var showLuckyLosersPopup = false
    @State private var roundPairs: [(Girl, Girl)] = []

    var onExit: () -> Void = {}

    private let firebaseService = FirebaseGirlService()

    // Define your primary and exit colors for button gradients
    let primaryColors = [
        Color(#colorLiteral(red: 0.239, green: 0.674, blue: 0.969, alpha: 1)),
        Color(#colorLiteral(red: 0.259, green: 0.757, blue: 0.969, alpha: 1))
    ]
    let exitColors = [
        Color(#colorLiteral(red: 0.808, green: 0.027, blue: 0.333, alpha: 1)),
        Color(#colorLiteral(red: 0.936, green: 0, blue: 0, alpha: 1))
    ]

    var primaryGradient: LinearGradient {
        LinearGradient(colors: primaryColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var exitGradient: LinearGradient {
        LinearGradient(colors: exitColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    init(roundType: RoundType = .qualifying, onExit: @escaping () -> Void = {}) {
        self._roundType = State(initialValue: roundType)
        self.onExit = onExit
    }

    var girlsInRound: [Girl] {
        girls.filter { $0.currentRound == roundType.roundNumber }
    }

    var totalGirlsInRound: Int { girlsInRound.count }

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Učitavanje...")
                        .font(.title)
                        .padding()
                    Spacer()
                } else {
                    VStack {
                        Text(roundType.rawValue)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(roundType.color)
                            .padding()

                        HStack(spacing: 40) {
                            Text("Ukupno devojaka u ovoj rundi: \(totalGirlsInRound)")
                            Text("Preostalo devojaka na turniru: \(remainingGirls)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    .padding()

                    if currentMatchIndex < roundPairs.count {
                        let pair = roundPairs[currentMatchIndex]
                        VStack(spacing: 12) {
                            GirlCardView(girl: pair.0) {
                                pickWinner(girl: pair.0)
                            }
                            .id(pair.0.id)

                            GirlCardView(girl: pair.1) {
                                pickWinner(girl: pair.1)
                            }
                            .id(pair.1.id)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 30)
                    } else {
                        Text("Runda završena!")
                            .font(.title)
                            .padding()

                        if let next = roundType.nextRound {
                            Button("Nastavi na \(next.rawValue)") {
                                proceedToNextRound(next)
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Text("Turnir je završen!")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                    }

                    Spacer()

                    ModernButton(
                        label: "Nazad na početni ekran",
                        gradient: primaryGradient,
                        shadowColor: primaryColors.first ?? .purple,
                        action: onExit
                    )
                    .padding(.horizontal, 40)
                    .offset(x: 8)  // <-- move the button 15 points right to look more centered
                }
            }

            // Custom popup overlay
            if showLuckyLosersPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .zIndex(1)

                PopupView(
                    title: "Lucky Losers 🎲",
                    message: luckyLosers.map { $0.name }.joined(separator: "\n"),
                    onClose: {
                        withAnimation {
                            showLuckyLosersPopup = false
                        }
                        resetRound(.round128)
                    }
                )
                .transition(.scale)
                .zIndex(2)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadGirlsFromFirebase()
        }
    }

    // ... your existing functions below, unchanged ...

    func loadGirlsFromFirebase() {
        firebaseService.fetchGirls { fetchedGirls in
            DispatchQueue.main.async {
                for i in 0..<fetchedGirls.count {
                    fetchedGirls[i].currentRound = fetchedGirls[i].isFavorite ? RoundType.round128.roundNumber : RoundType.qualifying.roundNumber
                }

                self.girls = fetchedGirls
                self.remainingGirls = fetchedGirls.count
                self.roundPairs = generateCurrentRoundPairs()
                self.isLoading = false
            }
        }
    }

    func generateCurrentRoundPairs() -> [(Girl, Girl)] {
        let girlsShuffled = girlsInRound.shuffled()
        var girlsWithImages = girlsShuffled.filter { !$0.imageUrls.isEmpty }
        var girlsWithoutImages = girlsShuffled.filter { $0.imageUrls.isEmpty }

        var pairs: [(Girl, Girl)] = []

        while !girlsWithoutImages.isEmpty && !girlsWithImages.isEmpty {
            let girlNoImage = girlsWithoutImages.removeFirst()
            let girlWithImage = girlsWithImages.removeFirst()
            pairs.append((girlWithImage, girlNoImage))
        }

        girlsWithImages.shuffle()
        for i in stride(from: 0, to: girlsWithImages.count - 1, by: 2) {
            pairs.append((girlsWithImages[i], girlsWithImages[i + 1]))
        }

        girlsWithoutImages.shuffle()
        for i in stride(from: 0, to: girlsWithoutImages.count - 1, by: 2) {
            pairs.append((girlsWithoutImages[i], girlsWithoutImages[i + 1]))
        }

        return pairs
    }

    func pickWinner(girl: Girl) {
        guard !winners.contains(where: { $0.id == girl.id }) else {
            print("⚠️ \(girl.name) already selected as winner. Ignored.")
            return
        }

        print("Prolaz dalje: \(girl.name) u rundi \(roundType.rawValue)")
        winners.append(girl)

        remainingGirls -= 1
        currentMatchIndex += 1

        if currentMatchIndex >= roundPairs.count {
            showNextRoundButton = true

            if roundType.nextRound == nil {
                finalizeTournament()
            }
        }
    }

    func proceedToNextRound(_ nextRound: RoundType) {
        print("Proceeding from \(roundType.rawValue) to \(nextRound.rawValue)")

        switch roundType {
        case .qualifying:
            advanceQualifyingWinners()
        default:
            for index in girls.indices {
                if winners.contains(where: { $0.id == girls[index].id }) {
                    girls[index].currentRound = nextRound.roundNumber
                } else if girls[index].currentRound == roundType.roundNumber {
                    girls[index].currentRound = -1
                }
            }

            resetRound(nextRound)
        }
    }

    private func advanceQualifyingWinners() {
        print("Advancing from QUALIFYING to ROUND128")

        let qualifyingGirls = girls.filter { $0.currentRound == RoundType.qualifying.roundNumber }
        let totalFavorites = girls.filter { $0.isFavorite }.count
        let round128Target = 128 - totalFavorites
        let winnersCount = winners.count

        var oddLuckyLoser: Girl? = nil
        if qualifyingGirls.count % 2 != 0 {
            let nonWinners = qualifyingGirls.filter { girl in
                !winners.contains(where: { $0.id == girl.id })
            }
            oddLuckyLoser = nonWinners.last
        }

        let luckyLosersNeeded = max(0, round128Target - winnersCount - (oddLuckyLoser == nil ? 0 : 1))

        let nonWinners = qualifyingGirls.filter { girl in
            !winners.contains(where: { $0.id == girl.id }) && girl.id != oddLuckyLoser?.id
        }

        let selectedLuckyLosers = Array(nonWinners.shuffled().prefix(luckyLosersNeeded))

        luckyLosers = selectedLuckyLosers
        if let odd = oddLuckyLoser {
            luckyLosers.append(odd)
        }

        for index in girls.indices {
            let girl = girls[index]
            if winners.contains(where: { $0.id == girl.id }) || luckyLosers.contains(where: { $0.id == girl.id }) {
                girls[index].currentRound = RoundType.round128.roundNumber
            } else if girl.currentRound == RoundType.qualifying.roundNumber {
                girls[index].currentRound = -1
            }
        }

        remainingGirls = girls.filter { $0.currentRound == RoundType.round128.roundNumber }.count

        if !luckyLosers.isEmpty {
            withAnimation {
                showLuckyLosersPopup = true
            }
        } else {
            resetRound(.round128)
        }
    }

    private func resetRound(_ nextRound: RoundType) {
        roundType = nextRound
        winners.removeAll()
        currentMatchIndex = 0
        showNextRoundButton = false
        roundPairs = generateCurrentRoundPairs()
    }

    private func finalizeTournament() {
        guard let finalWinner = winners.first else {
            print("No final winner found.")
            return
        }

        print("🏆 Pobednik takmicenja: \(finalWinner.name)")

        if let index = girls.firstIndex(where: { $0.id == finalWinner.id }) {
            girls[index].wins += 1
            firebaseService.updateGirl(girls[index]) { success in
                if success {
                    print("Updated wins for winner \(finalWinner.name)")
                } else {
                    print("Failed to update winner \(finalWinner.name)")
                }
            }
        }
    }
}
