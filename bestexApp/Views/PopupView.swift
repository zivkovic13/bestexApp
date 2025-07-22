import SwiftUI

struct PopupView: View {
    let title: String
    let message: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // TITLE
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.purple)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            // MESSAGE
            ScrollView {
                Text(message)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // BUTTON
            Button(action: onClose) {
                Text("OK")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 340)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
        )
    }
}
