import SwiftUI

struct HomeView: View {
    var startAction: () -> Void
    var leaderboardAction: () -> Void

    var body: some View {
        ZStack {
            Color(.systemGray4)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text("Dobrodošli u izbor za \nMISS Zivkovic")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Text("Pripremite se za izbor najlepse devojke u konkurenciji od 210+ takmicarki")
                    .font(.body)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button(action: startAction) {
                    Text("Pokreni takmicenje")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(15)
                        .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)

                Button(action: leaderboardAction) {
                    Text("Rang lista")
                        .font(.headline)
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}
