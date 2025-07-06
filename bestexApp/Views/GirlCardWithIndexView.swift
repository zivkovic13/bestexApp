//
//  GirlCardWithIndexView.swift
//  bestexApp
//
//  Created by MacBook Pro on 6. 7. 2025..
//

import SwiftUI

struct GirlCardWithIndexView: View {
    var girl: Girl
    var indexInRound: Int
    var onSelect: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            GirlCardView(girl: girl, onSelect: onSelect)
                .frame(height: 300)
                .cornerRadius(16)
                .shadow(radius: 6)

            // Index badge
            Text("\(indexInRound)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
                .offset(x: -10, y: 10)
                .shadow(radius: 3)
        }
    }
}
