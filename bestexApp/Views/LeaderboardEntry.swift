//
//  LeaderboardEntry.swift
//  bestexApp
//
//  Created by MacBook Pro on 1. 7. 2025..
//


import SwiftUI

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let wins: Int
}

struct LeaderboardView: View {
    var onBack: () -> Void = {}

    // Dummy leaderboard data
    let leaderboard = [
        LeaderboardEntry(name: "Girl 1", wins: 10),
        LeaderboardEntry(name: "Girl 2", wins: 8),
        LeaderboardEntry(name: "Girl 3", wins: 6),
        LeaderboardEntry(name: "Girl 4", wins: 4),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
                .padding()

            List(leaderboard) { entry in
                HStack {
                    Text(entry.name)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("\(entry.wins)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }

            Button("Back") {
                onBack()
            }
            .foregroundColor(.red)
            .padding()
        }
    }
}
