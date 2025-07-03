//
//  LeaderboardView.swift
//  bestexApp
//
//  Created by MacBook Pro on 3. 7. 2025..
//

import SwiftUI

struct LeaderboardView: View {
    @State private var girls: [Girl] = []
    @State private var isLoading = true

    private let firebaseService = FirebaseGirlService()

    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Text("Rang lista")
                .font(.largeTitle)
                .bold()
                .padding()

            if isLoading {
                ProgressView()
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
            }

            Button("Nazad na pocetni ekran") {
                onBack()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .cornerRadius(15)
            .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 40)  // << Add this line
        }
        .onAppear {
            loadLeaderboard()
        }
    }

    func loadLeaderboard() {
        firebaseService.fetchGirls { fetchedGirls in
            DispatchQueue.main.async {
                // Sort girls by wins descending before assigning
                self.girls = fetchedGirls.sorted(by: { $0.wins > $1.wins })
                self.isLoading = false
            }
        }
    }
}
