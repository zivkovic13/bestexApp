import SwiftUI

struct GirlCardView: View {
    var girl: Girl
    var onSelect: () -> Void

    @State private var currentImageIndex = 0

    private let baseImageURL = "https://mizitsolutions.com/wp-content/uploads"

    var nameLines: (first: String, last: String) {
        let parts = girl.name.split(separator: " ", maxSplits: 1).map(String.init)
        return (
            first: parts.first ?? "",
            last: parts.count > 1 ? parts.last! : ""
        )
    }

    var currentImageURL: URL? {
        guard !girl.imageUrls.isEmpty,
              currentImageIndex >= 0,
              currentImageIndex < girl.imageUrls.count else {
            print("❌ No image URLs for girl: \(girl.name)")
            return nil
        }

        let rawURL = girl.imageUrls[currentImageIndex]

        // If already full URL (starts with http), just use it directly (percent-encoded)
        if rawURL.lowercased().hasPrefix("http") {
            let encoded = rawURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? rawURL
            print("🌐 Final image URL for \(girl.name): \(encoded)")
            return URL(string: encoded)
        } else {
            print("⚠️ Expected full URL but got relative path: \(rawURL)")
            return nil
        }
    }
    


    var body: some View {
        VStack {
            ZStack {
                if let url = currentImageURL {
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
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 150, height: 200)
                        .overlay(Text("No Image").foregroundColor(.white))
                }

                // Arrows are shown when there are more then 1 image for girl
                if girl.imageUrls.count > 1 {
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                withAnimation {
                                    currentImageIndex = (currentImageIndex - 1 + girl.imageUrls.count) % girl.imageUrls.count
                                }
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.blue)
                            }

                            Spacer()

                            Button {
                                withAnimation {
                                    currentImageIndex = (currentImageIndex + 1) % girl.imageUrls.count
                                }
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }
                    .frame(width: 150, height: 200)
                }
            }
            .frame(height: 200)
            .clipped()

            VStack(spacing: 2) {
                Text(nameLines.first)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(nameLines.last)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 150)

            Text("Godište: \(girl.yearBorn)")
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
    
    func fetchImagesForGirl(city: String, name: String, completion: @escaping ([String]) -> Void) {
        let baseURL = "https://mizitsolutions.com/list-images.php"
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let nameEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }

        let urlString = "\(baseURL)?city=\(cityEncoded)&name=\(nameEncoded)"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let imageNames = try? JSONDecoder().decode([String].self, from: data) {
                completion(imageNames)
            } else {
                print("❌ Failed to load image list for \(name): \(error?.localizedDescription ?? "unknown error")")
                completion([])
            }
        }.resume()
    }

}
