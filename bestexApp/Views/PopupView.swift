//
//  PopupView.swift
//  bestexApp
//
//  Created by MacBook Pro on 5. 7. 2025..
//
import SwiftUI


struct PopupView: View {
    let title: String
    let message: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .padding(.top)

            ScrollView {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Got it!") {
                onClose()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple, lineWidth: 2)
        )
    }
}
