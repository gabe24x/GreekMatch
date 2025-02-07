//
//  ProfileImageGridView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/5/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct ProfileImageGridView: View {
    @Binding var profileImageURLs: [String]
    
    @State private var showImagePicker = false
    @State private var selectedUIImage: UIImage? = nil
    
    // Track which index user tapped
    @State private var tappedIndex: Int? = nil
    
    // Error handling
    @State private var uploadErrorMessage: String = ""
    @State private var showUploadErrorAlert: Bool = false
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0 ..< 6) { index in
                    ZStack {
                        if index < profileImageURLs.count {
                            // Display the remote URL via AsyncImage
                            let urlString = profileImageURLs[index]
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        // Show fallback if the URL fails
                                        Color.red.opacity(0.3)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: imageWidth, height: imageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .contextMenu {
                                    Button("Delete") {
                                        removeImage(at: index)
                                    }
                                    Button("Move Up") {
                                        moveImage(from: index, to: index - 1)
                                    }
                                    Button("Move Down") {
                                        moveImage(from: index, to: index + 1)
                                    }
                                }
                            } else {
                                // If the URL string is invalid
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray)
                                    .frame(width: imageWidth, height: imageHeight)
                            }
                            
                        } else {
                            ZStack(alignment: .bottomTrailing) {
                                // Empty slot
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: imageWidth, height: imageHeight)
                                
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color(.pink))
                                    .offset(x: 4, y: 4)
                            }
                        }
                    }
                    .onTapGesture {
                        // If it's empty, open the picker
                        if index >= profileImageURLs.count {
                            tappedIndex = index
                            showImagePicker = true
                        }
                    }
                }
            }
            // Present the image picker
            .sheet(isPresented: $showImagePicker, onDismiss: handleNewImage) {
                ImagePicker(selectedImage: $selectedUIImage)
            }
        }
        // Alert for upload errors
        .alert(isPresented: $showUploadErrorAlert) {
            Alert(
                title: Text("Upload Error"),
                message: Text(uploadErrorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Helpers
    private func removeImage(at index: Int) {
        guard index < profileImageURLs.count else { return }
        profileImageURLs.remove(at: index)
    }
    
    private func moveImage(from oldIndex: Int, to newIndex: Int) {
        guard oldIndex < profileImageURLs.count else { return }
        guard newIndex >= 0 && newIndex < profileImageURLs.count else { return }
        
        let item = profileImageURLs.remove(at: oldIndex)
        profileImageURLs.insert(item, at: newIndex)
    }
    
    private func handleNewImage() {
        guard let uiImage = selectedUIImage else { return }
        
        // Convert to JPEG data
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else { return }
        
        // 1) Generate unique path in Storage (e.g., "profileImages/UUID.jpg")
        let filename = "profileImages/\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child(filename)
        
        // 2) Upload to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload: \(error.localizedDescription)")
                uploadErrorMessage = "Failed to upload image. Please try again."
                showUploadErrorAlert = true
                return
            }
            
            // 3) On success, fetch the download URL
            storageRef.downloadURL { url, error in
                if let url = url {
                    DispatchQueue.main.async {
                        // Insert or replace in our array
                        if let index = tappedIndex {
                            if index < profileImageURLs.count {
                                // Replace existing at that index
                                profileImageURLs[index] = url.absoluteString
                            } else {
                                // Append new
                                profileImageURLs.append(url.absoluteString)
                            }
                        }
                        
                        // Reset
                        tappedIndex = nil
                        selectedUIImage = nil
                    }
                } else {
                    uploadErrorMessage = "Failed to retrieve image URL. Please try again."
                    showUploadErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Layout
    private var columns: [GridItem] {
        [
            .init(.flexible()),
            .init(.flexible()),
            .init(.flexible())
        ]
    }
    
    private var imageWidth: CGFloat { 110 }
    private var imageHeight: CGFloat { 160 }
}

struct ProfileImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageGridView(profileImageURLs: .constant(["https://example.com/image1.jpg"]))
    }
}
