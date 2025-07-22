import SwiftUI

struct PravilnikView: View {
    var onBack: () -> Void

    let primaryColors = [
        Color(#colorLiteral(red: 0.239, green: 0.674, blue: 0.969, alpha: 1)),
        Color(#colorLiteral(red: 0.259, green: 0.757, blue: 0.969, alpha: 1))
    ]
    var primaryGradient: LinearGradient {
        LinearGradient(colors: primaryColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gray background with subtle gradient for depth
                LinearGradient(
                    colors: [
                        Color(red: 28/255, green: 28/255, blue: 30/255),
                        Color(red: 45/255, green: 45/255, blue: 48/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("📜 Pravilnik")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(primaryGradient)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                            .frame(maxWidth: .infinity)

                        Group {
                            Text("📌 Takmičenje")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Takmičenje se odvija u eliminacionim rundama sve do finala. Parovi su u svakoj rundi nasumično odabrani.")
                                .font(.body)
                                .foregroundColor(Color.white.opacity(0.75))

                            Divider()
                                .background(Color.white.opacity(0.3))

                            Text("⭐️ Favoriti")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Na turniru postoji 10 favorita po izboru kreatora. Favoriti preskacu kvalifikacije i ulaze direktno u glavni žreb (Runda 128).")
                                .font(.body)
                                .foregroundColor(Color.white.opacity(0.75))

                            Divider()
                                .background(Color.white.opacity(0.3))

                            Text("🎲 Lucky losers")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("U slučaju da broj devojaka za glavni žreb nije 128, nasumično se vraća jedna ili više eliminisanih devojaka kao lucky losers.")
                                .font(.body)
                                .foregroundColor(Color.white.opacity(0.75))

                            Divider()
                                .background(Color.white.opacity(0.3))

                            Text("🚫 Devojke bez slika")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("U takmicenje su ubacene sve devojke, čak i one za koje još nisu pribavljene slike. Devojke bez slika se takmiče regularno kao i one sa slikom, s tim što one ne mogu biti izabrane kao lucky losers.")
                                .font(.body)
                                .foregroundColor(Color.white.opacity(0.75))
                        }

                        Spacer(minLength: 40)

                        ModernButton(
                            label: "Nazad na početni ekran",
                            gradient: primaryGradient,
                            shadowColor: primaryColors.first ?? .purple,
                            action: onBack
                        )
                        .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.7), radius: 12, x: 0, y: 6)
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
