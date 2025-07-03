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
    @State private var showLuckyLosersAlert = false

    var onExit: () -> Void = {}

    private let firebaseService = FirebaseGirlService()

    init(roundType: RoundType = .qualifying, onExit: @escaping () -> Void = {}) {
        self._roundType = State(initialValue: roundType)
        self.onExit = onExit
    }

    var girlsInRound: [Girl] {
        girls.filter { $0.currentRound == roundType.roundNumber }
    }

    var totalGirlsInRound: Int { girlsInRound.count }

    var body: some View {
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

                if currentMatchIndex * 2 + 1 < girlsInRound.count {
                    HStack(spacing: 20) {
                        GirlCardView(girl: girlsInRound[currentMatchIndex * 2]) {
                            pickWinner(girl: girlsInRound[currentMatchIndex * 2])
                        }
                        GirlCardView(girl: girlsInRound[currentMatchIndex * 2 + 1]) {
                            pickWinner(girl: girlsInRound[currentMatchIndex * 2 + 1])
                        }
                    }
                    .padding(.horizontal)
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

                Button("Nazad na pocetni ekran") {
                    onExit()
                }
                .padding()
                .foregroundColor(.red)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showLuckyLosersAlert) {
            Alert(
                title: Text("Lucky losers:"),
                message: Text(luckyLosers.map { $0.name }.joined(separator: ", ")),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            loadGirlsFromFirebase()
        }
    }

    func loadGirlsFromFirebase() {
        firebaseService.fetchGirls { fetchedGirls in
            DispatchQueue.main.async {
                var updatedGirls = fetchedGirls

                // Assign rounds: favorites start at round64 (2), others at qualifying (0)
                for i in 0..<updatedGirls.count {
                    updatedGirls[i].currentRound = updatedGirls[i].isFavorite ? RoundType.round64.roundNumber : RoundType.qualifying.roundNumber
                }

                self.girls = updatedGirls
                self.remainingGirls = updatedGirls.count
                print("Loaded \(updatedGirls.count) girls. Assigned rounds: favorites to round64, others qualifying.")
                self.isLoading = false
            }
        }
    }

    func pickWinner(girl: Girl) {
        print("Pobednik: \(girl.name) u rundi \(roundType.rawValue)")
        winners.append(girl)

        remainingGirls -= 1
        currentMatchIndex += 1

        if currentMatchIndex * 2 >= girlsInRound.count {
            print("Round \(roundType.rawValue) finished with \(winners.count) winners.")
            showNextRoundButton = true
        }
    }

    func proceedToNextRound(_ nextRound: RoundType) {
        print("Proceeding from \(roundType.rawValue) to \(nextRound.rawValue)")

        switch roundType {
        case .qualifying:
            advanceQualifyingWinners()
        default:
            // For rounds after qualifying (round64, 32, etc.)
            for index in girls.indices {
                if winners.contains(where: { $0.id == girls[index].id }) {
                    girls[index].currentRound = nextRound.roundNumber
                } else if girls[index].currentRound == roundType.roundNumber {
                    girls[index].currentRound = -1 // eliminated
                }
            }
            resetRound(nextRound)
        }
    }

    private func advanceQualifyingWinners() {
        let qualifyingGirls = girls.filter { $0.currentRound == RoundType.qualifying.roundNumber }
        let totalFavorites = girls.filter { $0.isFavorite }.count
        let round64Target = 128 - totalFavorites  // total needed to fill round64

        let winnersCount = winners.count

        // Odd girl handling
        var oddLuckyLoser: Girl? = nil
        if qualifyingGirls.count % 2 != 0 {
            let nonWinnersInQualifying = qualifyingGirls.filter { girl in
                !winners.contains(where: { $0.id == girl.id })
            }
            if let oddGirl = nonWinnersInQualifying.last {
                oddLuckyLoser = oddGirl
                print("Odd girl (unpaired) automatically lucky loser: \(oddGirl.name)")
            }
        }

        // Lucky losers needed (excluding odd one)
        let luckyLosersNeeded = max(0, round64Target - winnersCount - (oddLuckyLoser == nil ? 0 : 1))
        print("Qualifying winners: \(winnersCount), lucky losers needed (excluding odd one): \(luckyLosersNeeded)")

        // Random lucky losers from non-winners excluding oddLuckyLoser
        let nonWinnersInQualifying = qualifyingGirls.filter { girl in
            !winners.contains(where: { $0.id == girl.id }) && girl.id != oddLuckyLoser?.id
        }
        let randomLuckyLosers = Array(nonWinnersInQualifying.shuffled().prefix(luckyLosersNeeded))

        // Combine oddLuckyLoser + random lucky losers
        luckyLosers = randomLuckyLosers
        if let odd = oddLuckyLoser {
            luckyLosers.append(odd)
        }

        // Update rounds for winners and lucky losers directly to round64
        for index in girls.indices {
            let girl = girls[index]
            if winners.contains(where: { $0.id == girl.id }) || luckyLosers.contains(where: { $0.id == girl.id }) {
                girls[index].currentRound = RoundType.round64.roundNumber
            } else if girl.currentRound == RoundType.qualifying.roundNumber {
                girls[index].currentRound = -1 // eliminated
            }
        }

        // Update remainingGirls accordingly
        remainingGirls = totalFavorites + winnersCount + luckyLosers.count

        resetRound(.round64)

        // Show lucky losers alert
        showLuckyLosersAlert = !luckyLosers.isEmpty
        print("Lucky losers advancing: \(luckyLosers.map { $0.name }.joined(separator: ", "))")
    }

    private func resetRound(_ nextRound: RoundType) {
        roundType = nextRound
        winners.removeAll()
        currentMatchIndex = 0
        showNextRoundButton = false
    }
}
