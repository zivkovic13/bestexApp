//
//  ModernButton.swift
//  bestexApp
//
//  Created by MacBook Pro on 6. 7. 2025..
//


// ModernButton.swift

import SwiftUI

struct ModernButton: View {
    var label: String
    var gradient: LinearGradient
    var shadowColor: Color
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            Text(label)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(gradient)
                .cornerRadius(20)
                .shadow(color: shadowColor.opacity(0.6), radius: 10, x: 0, y: 5)
                .scaleEffect(isPressed ? 0.95 : 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
