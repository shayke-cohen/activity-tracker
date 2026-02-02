import SwiftUI

/// View for sharing workout to social media
struct ShareWorkoutView: View {
    let activity: Activity
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ShareFormat = .square
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview
                Text("PREVIEW")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Card preview
                ShareCardContent(activity: activity, format: selectedFormat)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                
                // Format picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("FORMAT")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ShareFormat.allCases.filter { $0 != .text }) { format in
                                FormatButton(
                                    format: format,
                                    isSelected: format == selectedFormat
                                ) {
                                    selectedFormat = format
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Share buttons
                VStack(spacing: 12) {
                    Text("SHARE TO")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ShareDestinationButton(
                            icon: "camera.fill",
                            label: "Instagram",
                            color: .purple
                        ) {
                            shareToInstagram()
                        }
                        
                        ShareDestinationButton(
                            icon: "bubble.left.fill",
                            label: "Messages",
                            color: .green
                        ) {
                            shareToMessages()
                        }
                        
                        ShareDestinationButton(
                            icon: "square.and.arrow.down",
                            label: "Save",
                            color: .blue
                        ) {
                            saveToPhotos()
                        }
                        
                        ShareDestinationButton(
                            icon: "doc.on.doc",
                            label: "Copy",
                            color: .gray
                        ) {
                            copyStats()
                        }
                        
                        ShareDestinationButton(
                            icon: "ellipsis",
                            label: "More",
                            color: .secondary
                        ) {
                            showShareSheet()
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Share Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Share Actions
    
    private func shareToInstagram() {
        // Would integrate with Instagram Stories API
        showShareSheet()
    }
    
    private func shareToMessages() {
        showShareSheet()
    }
    
    private func saveToPhotos() {
        guard let image = ShareService.shared.generateShareImage(for: activity, format: selectedFormat) else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func copyStats() {
        let text = ShareService.shared.generateTextSummary(for: activity)
        UIPasteboard.general.string = text
    }
    
    private func showShareSheet() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        ShareService.shared.share(activity: activity, format: selectedFormat, from: viewController)
    }
}

// MARK: - Format Button

struct FormatButton: View {
    let format: ShareFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: aspectWidth, height: aspectHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                
                Text(format.rawValue)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var aspectWidth: CGFloat {
        switch format {
        case .instagramStory: return 36
        case .square: return 50
        case .wide: return 60
        case .text: return 50
        }
    }
    
    private var aspectHeight: CGFloat {
        switch format {
        case .instagramStory: return 64
        case .square: return 50
        case .wide: return 32
        case .text: return 50
        }
    }
}

// MARK: - Share Destination Button

struct ShareDestinationButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShareWorkoutView(activity: .sampleRun)
}
