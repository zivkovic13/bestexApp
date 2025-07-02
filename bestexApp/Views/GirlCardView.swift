//
//  GirlCardView.swift
//  bestexApp
//
//  Created by MacBook Pro on 2. 7. 2025..
//

import SwiftUI

struct GirlCardView: View {
    var girl: Girl
    var onSelect: () -> Void

    var body: some View {
        VStack {
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
