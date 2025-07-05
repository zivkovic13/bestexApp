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
    
    // pairs for current round, avoiding favorites vs favorites until R16
    var currentRoundPairs: [(Girl, Girl)] {
        
//        let girlsThisRound: Int { girlsInRound.shuffled() }
        
        // Rounds where favorites can't face each other:
        let restrictedRounds: [RoundType] = [.round64, .round32, .round16]
        
        if restrictedRounds.contains(roundType) {
            let favs = girlsInRound.filter { $0.isFavorite }
            let nonFavs = girlsInRound.filter { !$0.isFavorite }

            var pairs: [(Girl, Girl)] = []

            // Pair favorites with non-favorites first
            let pairCount = min(favs.count, nonFavs.count)
            for i in 0..<pairCount {
                pairs.append((favs[i], nonFavs[i]))
            }

            // Pair leftover favorites among themselves (if any)
            let leftoverFavs = Array(favs.dropFirst(pairCount))
            for i in stride(from: 0, to: leftoverFavs.count - 1, by: 2) {
                pairs.append((leftoverFavs[i], leftoverFavs[i + 1]))
            }

            // Pair leftover non-favorites among themselves (if any)
            let leftoverNonFavs = Array(nonFavs.dropFirst(pairCount))
            for i in stride(from: 0, to: leftoverNonFavs.count - 1, by: 2) {
                pairs.append((leftoverNonFavs[i], leftoverNonFavs[i + 1]))
            }

            return pairs
        } else {
            // From round8 onward, normal pairing by sequence
            var pairs: [(Girl, Girl)] = []
            for i in stride(from: 0, to: girlsInRound.count - 1, by: 2) {
                pairs.append((girlsInRound[i], girlsInRound[i + 1]))
            }
            return pairs
        }
    }

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

                if currentMatchIndex < currentRoundPairs.count {
                    let pair = currentRoundPairs[currentMatchIndex]
                    HStack(spacing: 20) {
                        GirlCardView(girl: pair.0) {
                            pickWinner(girl: pair.0)
                        }
                        .id(pair.0.id)

                        GirlCardView(girl: pair.1) {
                            pickWinner(girl: pair.1)
                        }
                        .id(pair.1.id)
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
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(15)
                .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showLuckyLosersAlert) {
            Alert(
                title: Text("Lucky losers:"),
                message: Text(luckyLosers.map { $0.name }.joined(separator: ",\n ")),
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
                let updatedGirls = fetchedGirls

                // Assign rounds: favorites start at round64 (2), others at qualifying (0)
                for i in 0..<updatedGirls.count {
                    updatedGirls[i].currentRound = updatedGirls[i].isFavorite ? RoundType.round128.roundNumber : RoundType.qualifying.roundNumber
                }

                self.girls = updatedGirls
                self.remainingGirls = updatedGirls.count
                print("Loaded \(updatedGirls.count) girls. Assigned rounds: favorites to round64, others qualifying.")
                self.isLoading = false
            }
        }
    }

    func pickWinner(girl: Girl) {
        print("Prolaz dalje: \(girl.name) u rundi \(roundType.rawValue)")
        winners.append(girl)

        remainingGirls -= 1
        currentMatchIndex += 1

        if currentMatchIndex >= currentRoundPairs.count {
            showNextRoundButton = true
            
            if roundType.nextRound == nil {
                // Final round just finished - finalize tournament
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
        let round128Target = 128 - totalFavorites  // total needed to fill round64

        let winnersCount = winners.count

        // Odd/Unpaired girl handling - code block for when number of girls is ODD ie 215
        var oddLuckyLoser: Girl? = nil
        if qualifyingGirls.count % 2 != 0 {
            let nonWinnersInQualifying = qualifyingGirls.filter { girl in
                !winners.contains(where: { $0.id == girl.id })
            }
            if let oddGirl = nonWinnersInQualifying.last {
                oddLuckyLoser = oddGirl
                print("\nOdd girl (unpaired) automatically lucky loser: \(oddGirl.name)\n")
            }
        }

        // Lucky losers needed (excluding unpaired one)
        let luckyLosersNeeded = max(0, round128Target - winnersCount - (oddLuckyLoser == nil ? 0 : 1))
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

        // Update rounds for winners and lucky losers directly to round128
        for index in girls.indices {
            let girl = girls[index]
            if winners.contains(where: { $0.id == girl.id }) || luckyLosers.contains(where: { $0.id == girl.id }) {
                girls[index].currentRound = RoundType.round128.roundNumber
            } else if girl.currentRound == RoundType.qualifying.roundNumber {
                girls[index].currentRound = -1 // eliminated
            }
        }

        // Update remainingGirls accordingly
        remainingGirls = totalFavorites + winnersCount + luckyLosers.count

        resetRound(.round128)

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
                    print("✅ Updated wins for winner \(finalWinner.name)")
                } else {
                    print("❌ Failed to update winner \(finalWinner.name)")
                }
            }
        }
    }
}
