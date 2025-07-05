    import SwiftUI
    import Foundation

    struct GirlCardView: View {
        var girl: Girl
        var onSelect: () -> Void

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
                            .overlay(Text("No image").foregroundColor(.white))
                    }

                    if imageUrls.count > 1 {
                        VStack {
                            Spacer()
                            HStack {
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

                                Spacer()

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

                Text("Godište: \(String(girl.yearBorn))")
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
            .onAppear {
                loadImages()
            }
            .onChange(of: girl) {
                currentImageIndex = 0
                loadImages()
            }
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
                        folderPrefix = "Ostalo/\(encodedCity)/\(encodedName)"
                    }


                    self.imageUrls = fileNames.compactMap { fileName in
                        let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
                        let fullURLString = "\(baseImageURL)/\(folderPrefix)/\(encodedFileName)"
                        print("🔗 Final image URL: \(fullURLString)")
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
                    print("❌ Failed to load image list for \(name): \(error?.localizedDescription ?? "unknown error")")
                    completion([])
                }
            }.resume()
        }
    }
