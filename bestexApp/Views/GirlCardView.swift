import SwiftUI

struct GirlCardView: View {
    var girl: Girl
    var onSelect: () -> Void
    var indexInRound: Int? = nil  // optional index to show as a corner counter

    @State private var currentImageIndex = 0
    @State private var imageUrls: [URL] = []

    private let baseImageURL = "https://mizitsolutions.com/wp-content/uploads/girls"

    var nameLines: (first: String, last: String) {
        let parts = girl.name.split(separator: " ", maxSplits: 1).map(String.init)
        return (
            first: parts.first ?? "",
            last: parts.count > 1 ? parts.last! : ""
        )
    }

    var currentImageURL: URL? {
        guard !imageUrls.isEmpty,
              currentImageIndex >= 0,
              currentImageIndex < imageUrls.count else {
            return nil
        }
        return imageUrls[currentImageIndex]
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    if let url = currentImageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.9)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.9)
                                    .clipped()
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.9)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.9)
                            .cornerRadius(12)
                            .overlay(Text("No image").foregroundColor(.white))
                    }

                    if let idx = indexInRound {
                        Text("\(idx)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(6)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(nameLines.first)
                        .font(.title3)
                        .bold()
                    Text(nameLines.last)
                        .font(.title3)
                        .bold()
                    Text("Godište: \(girl.yearBorn)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Mesto: \(girl.city)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    if imageUrls.count > 1 {
                        HStack(spacing: 15) {
                            Button {
                                withAnimation {
                                    currentImageIndex = (currentImageIndex - 1 + imageUrls.count) % imageUrls.count
                                }
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.blue)
                            }

                            Button {
                                withAnimation {
                                    currentImageIndex = (currentImageIndex + 1) % imageUrls.count
                                }
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 10)

                    }
                }
                .frame(width: geo.size.width * 0.45)
                .padding(.vertical, 10)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(radius: 4)
            .onTapGesture {
                onSelect()
            }
            .onAppear {
                loadImages()
            }
            .onChange(of: girl) { _ in
                currentImageIndex = 0
                loadImages()
            }
        }
        .frame(height: 220) // fixed height for card
    }


    private func loadImages() {
        let validCityFolders: Set<String> = [
            "Beograd", "Mihajlovac", "Mladenovac", "Nis", "Pozarevac",
            "Smederevo", "Smederevska Palanka", "Velika Plana"
        ]

        imageUrls = []

        fetchImagesForGirl(city: girl.city, name: girl.name) { fileNames in
            DispatchQueue.main.async {
                let encodedCity = girl.city.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? girl.city
                let encodedName = girl.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? girl.name

                let folderPrefix: String
                if validCityFolders.contains(girl.city) {
                    folderPrefix = "\(encodedCity)/\(encodedName)"
                } else {
                    folderPrefix = "/Ostalo/\(encodedCity)/\(encodedName)"
                }

                self.imageUrls = fileNames.compactMap { fileName in
                    let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
                    let fullURLString = "\(baseImageURL)/\(folderPrefix)/\(encodedFileName)"
                    return URL(string: fullURLString)
                }

                self.currentImageIndex = 0
            }
        }
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
                print("Failed to load image list for \(name): \(error?.localizedDescription ?? "unknown error")")
                completion([])
            }
        }.resume()
    }
}

