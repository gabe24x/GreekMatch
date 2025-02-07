//
//  UserProfileView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentImageIndex = 0
    
    let user: User
    
    var body: some View {
        VStack {
            HStack {
                Text(user.fullname)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.down.circle.fill")
                        .imageScale(.large)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white, Color.pink)
                }
            }
            .padding()
            
            ScrollView {
                VStack {
                    ZStack(alignment: .top) {
                        // Safely unwrap profileImageURLs
                        if let urls = user.profileImageURLs,
                           !urls.isEmpty,
                           let imageUrl = URL(string: urls[currentImageIndex]) {
                            
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    // Fallback if the URL fails
                                    Color.red.opacity(0.3)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: SizeConstants.cardWidth, height: SizeConstants.cardHeight)
                            .overlay {
                                ImageScrollingOverlay(
                                    currentImageIndex: $currentImageIndex,
                                    imageCount: urls.count
                                )
                            }
                            
                            CardImageIndicatorView(
                                currentImageIndex: currentImageIndex,
                                imageCount: urls.count
                            )
                        } else {
                            // Fallback if user.profileImageURLs is nil or empty
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: SizeConstants.cardWidth, height: SizeConstants.cardHeight)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About me")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let bio = user.bio, !bio.isEmpty {
                            // Bio exists
                            Text(bio)
                                .font(.subheadline)
                                .lineLimit(nil)
                        } else {
                            // Fallback: Empty Bio
                            Text("No bio yet.")
                                .font(.subheadline)
                                .lineLimit(nil)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .font(.subheadline)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Greek Affiliation & Year")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text(user.greekAffiliation)
                            Spacer()
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Image(systemName: "book")
                            Text(user.grade)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .font(.subheadline)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

// MARK: - Preview

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(
            id: "user123",
            fullname: "John Doe",
            email: "john@example.com",
            grade: "Junior",
            greekAffiliation: "Theta Chi",
            profileImageURLs: ["https://example.com/image1.jpg"],
            bio: "Hello! I'm John."
        )
        
        UserProfileView(user: sampleUser)
    }
}
