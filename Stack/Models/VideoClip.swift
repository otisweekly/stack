import Foundation
import UIKit

/// Represents an imported media clip (video or image)
struct VideoClip: Identifiable, Equatable {
    let id: UUID
    let url: URL
    var thumbnailURL: URL?
    let duration: TimeInterval
    let isVideo: Bool
    let size: CGSize

    init(
        id: UUID = UUID(),
        url: URL,
        thumbnailURL: URL? = nil,
        duration: TimeInterval,
        isVideo: Bool = true,
        size: CGSize
    ) {
        self.id = id
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.isVideo = isVideo
        self.size = size
    }

    /// Aspect ratio of the clip (width / height)
    var aspectRatio: CGFloat {
        guard size.height > 0 else { return 1 }
        return size.width / size.height
    }
}
