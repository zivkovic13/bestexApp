import SwiftUI

struct TournamentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var girls: [Girl] = []
    @State private var roundType: RoundType = .preliminary
    @State private var currentMatchIndex = 0
    @State private var winners: [Girl] = []
    @State private var remainingGirls: Int = 0
    @State private var isLoading = true
    @State private var showNextRoundButton = false

    var onExit: () -> Void = {}

    private let firebaseService = FirebaseGirlService()

    init(roundType: RoundType = .preliminary, onExit: @escaping () -> Void = {}) {
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
                        Text("Preostalo devojaka u turniru: \(remainingGirls)")
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

                Button("Exit") {
                    onExit()
                }
                .padding()
                .foregroundColor(.red)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadGirlsFromFirebase()
        }
    }

    func loadGirlsFromFirebase() {
        firebaseService.fetchGirls { fetchedGirls in
            DispatchQueue.main.async {
                self.girls = fetchedGirls.map {
                    var g = $0
                    g.currentRound = g.isFavorite ? RoundType.round64.roundNumber : RoundType.preliminary.roundNumber
                    return g
                }
                self.remainingGirls = self.girls.count
                print("Loaded \(self.girls.count) girls. Assigned currentRound based on favorites.")
                self.isLoading = false
            }
        }
    }

    func pickWinner(girl: Girl) {
        print("Pick winner: \(girl.name) in round \(roundType.rawValue)")
        winners.append(girl)

        remainingGirls -= 1  // Decrease total remaining girls in tournament by 1 per duel
        currentMatchIndex += 1

        if currentMatchIndex * 2 >= girlsInRound.count {
            print("Round \(roundType.rawValue) finished with \(winners.count) winners.")
            showNextRoundButton = true
        }
    }

    func proceedToNextRound(_ nextRound: RoundType) {
        print("Proceeding from \(roundType.rawValue) to \(nextRound.rawValue)")

        for index in girls.indices {
            if winners.contains(where: { $0.id == girls[index].id }) {
                girls[index].currentRound = nextRound.roundNumber
                print("Girl \(girls[index].name) advances to round \(nextRound.rawValue)")
            } else if girls[index].currentRound == roundType.roundNumber {
                girls[index].currentRound = -1
                print("Girl \(girls[index].name) eliminated at round \(roundType.rawValue)")
            }
        }

        // Reset for next round
        roundType = nextRound
        winners.removeAll()
        currentMatchIndex = 0
        showNextRoundButton = false
    }
}
