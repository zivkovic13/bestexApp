//
//  TournamentView.swift
//  bestexApp
//
//  Created by MacBook Pro on 30. 6. 2025..
//


import SwiftUI

struct TournamentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var girls: [Girl] = loadGirls()
    @State private var round: Int = 1
    @State private var totalGirls: Int
    @State private var remainingGirls: Int
    @State private var currentMatchIndex = 0

    @State private var winners: [Girl] = []
    var onExit: () -> Void = {}

    init(onExit: @escaping () -> Void = {}) {
        let allGirls = loadGirls()
        _girls = State(initialValue: allGirls)
        _totalGirls = State(initialValue: allGirls.count)
        _remainingGirls = State(initialValue: allGirls.count)
        self.onExit = onExit
    }

    var body: some View {
        VStack(spacing: 20) {
            // Top: round info + stats
            VStack {
                Text("Tournament Round: \(round)/64")
                    .font(.title2)
                    .bold()

                HStack(spacing: 40) {
                    Text("Total girls: \(totalGirls)")
                    Text("Remaining girls: \(remainingGirls)")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            .padding()

            // Middle: two girls side-by-side
            if currentMatchIndex * 2 + 1 < girls.count {
                HStack(spacing: 20) {
                    GirlCardView(girl: girls[currentMatchIndex * 2]) {
                        pickWinner(girl: girls[currentMatchIndex * 2])
                    }
                    GirlCardView(girl: girls[currentMatchIndex * 2 + 1]) {
                        pickWinner(girl: girls[currentMatchIndex * 2 + 1])
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Tournament complete!")
                    .font(.largeTitle)
                    .padding()
            }

            Spacer()

            Button("Exit") {
                onExit()
            }
            .padding()
            .foregroundColor(.red)
        }
        .navigationBarBackButtonHidden(true)
    }

    func pickWinner(girl: Girl) {
        // Move winner to next round list or update state
        // Simplified example:
        remainingGirls -= 1
        currentMatchIndex += 1

        if currentMatchIndex * 2 >= girls.count {
            // move to next round logic here (e.g., reduce girls array)
            round *= 2 // Just example, adjust accordingly
            currentMatchIndex = 0
            // reduce girls list to winners for next round - implement your logic here
        }
    }
}

struct GirlCardView: View {
    var girl: Girl
    var onSelect: () -> Void

    var body: some View {
        VStack {
            // Show image if you have one; placeholder for now
            Rectangle()
                .fill(Color.gray)
                .frame(width: 150, height: 200)
                .overlay(
                    Text("Image")
                        .foregroundColor(.white)
                )

            Text("\(girl.name)")
                .font(.headline)
            Text("Godine: \(girl.yearBorn)")
                .font(.subheadline)
            Text("Mesto: \(girl.city)")
                .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture {
            onSelect()
        }
        .shadow(radius: 5)
    }
}

// Dummy loadGirls() for demo
func loadGirls() -> [Girl] {
    (1...64).map { i in
        Girl(name: "Girl \(i)", yearBorn: 18 + (i % 10), city: "City \(i)", images: [])
    }
}
