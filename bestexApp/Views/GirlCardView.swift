import SwiftUI

struct GirlCardView: View {
    var girl: Girl
    var onSelect: () -> Void

    @State private var currentImageIndex = 0

    var body: some View {
        VStack {
            ZStack {
                if !girl.imageUrls.isEmpty,
                   let url = URL(string: girl.imageUrls[currentImageIndex]) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 200)
                                .clipped()
                        case .failure(let error):
                            VStack {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 200)
                                    .foregroundColor(.gray)
                                Text(error.localizedDescription)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding([.horizontal, .bottom], 4)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }

                    HStack {
                        Button {
                            withAnimation {
                                currentImageIndex = (currentImageIndex - 1 + girl.imageUrls.count) % girl.imageUrls.count
                            }
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                currentImageIndex = (currentImageIndex + 1) % girl.imageUrls.count
                            }
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .offset(y: 90) // tweak as needed
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 150, height: 200)
                        .overlay(Text("No Image").foregroundColor(.white))
                }
            }
            .frame(height: 200)
            .clipped()

            Text(girl.name)
                .font(.headline)
            Text("Godiste: \(girl.yearBorn)")
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
