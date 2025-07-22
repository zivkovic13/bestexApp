//
//  AnimatedBackground.swift
//  bestexApp
//
//  Created by MacBook Pro on 6. 7. 2025..
//


import SwiftUI

struct AnimatedBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.1, blue: 0.25),
                Color(red: 0.15, green: 0.15, blue: 0.3),
                Color(red: 0.2, green: 0.2, blue: 0.35),
                Color(red: 0.1, green: 0.1, blue: 0.25)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .animation(
            Animation.easeInOut(duration: 8).repeatForever(autoreverses: true),
            value: animateGradient
        )
        .onAppear {
            animateGradient = true
        }
        .ignoresSafeArea()
    }
}
