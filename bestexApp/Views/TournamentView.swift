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
    @State private var showLuckyLosersPopup = false
    @State private var roundPairs: [(Girl, Girl)] = []

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
                }

                    else {
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
        
        print("Total favorites already in round128: \(totalFavorites)")
        
        // Debug print the winners list and count before any processing
        print("Winners count before promotion: \(winners.count)")
        print("Winners: \(winners.map { $0.name })")
        
        let winnersCount = winners.count
        
        // Handle odd number of qualifying girls for lucky loser
        var oddLuckyLoser: Girl? = nil
        if qualifyingGirls.count % 2 != 0 {
            let nonWinnersInQualifying = qualifyingGirls.filter { girl in
                !winners.contains(where: { $0.id == girl.id })
            }
            if let oddGirl = nonWinnersInQualifying.last {
                oddLuckyLoser = oddGirl
                print("Odd unpaired lucky loser candidate: \(oddGirl.name)")
            }
        }
        
        let luckyLosersNeeded = max(0, round128Target - winnersCount - (oddLuckyLoser == nil ? 0 : 1))
        print("Lucky losers needed (excluding odd one): \(luckyLosersNeeded)")
        
        let nonWinnersInQualifying = qualifyingGirls.filter { girl in
            !winners.contains(where: { $0.id == girl.id }) && girl.id != oddLuckyLoser?.id
        }
        
        print("Non-winners available for lucky losers: \(nonWinnersInQualifying.count)")
        
        let randomLuckyLosers = Array(nonWinnersInQualifying.shuffled().prefix(luckyLosersNeeded))
        
        luckyLosers = randomLuckyLosers
        if let odd = oddLuckyLoser {
            luckyLosers.append(odd)
        }
        
        print("Lucky losers selected: \(luckyLosers.map { $0.name })")
        
        // Update girls' currentRound accordingly
        for index in girls.indices {
            let girl = girls[index]
            if winners.contains(where: { $0.id == girl.id }) || luckyLosers.contains(where: { $0.id == girl.id }) {
                girls[index].currentRound = RoundType.round128.roundNumber
            } else if girl.currentRound == RoundType.qualifying.roundNumber {
                girls[index].currentRound = -1 // eliminated
            }
        }
        
        let totalAdvanced = girls.filter { $0.currentRound == RoundType.round128.roundNumber }.count
        print("Total girls promoted to round128: \(totalAdvanced) (should be 128)")
        
        remainingGirls = totalAdvanced
        
        showLuckyLosersAlert = !luckyLosers.isEmpty
        
        resetRound(.round128)
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
                    print("✅ Updated wins for winner \(finalWinner.name)")
                } else {
                    print("❌ Failed to update winner \(finalWinner.name)")
                }
            }
        }
    }
}
