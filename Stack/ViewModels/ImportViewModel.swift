import SwiftUI
import PhotosUI

enum ImportState: Equatable {
    case idle
    case selecting
    case loading(progress: Double, loaded: Int, total: Int)
    case loaded(items: [MediaItem])
    case error(message: String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    static func == (lhs: ImportState, rhs: ImportState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.selecting, .selecting):
            return true
        case let (.loading(p1, l1, t1), .loading(p2, l2, t2)):
            return p1 == p2 && l1 == l2 && t1 == t2
        case let (.loaded(items1), .loaded(items2)):
            return items1.map(\.id) == items2.map(\.id)
        case let (.error(m1), .error(m2)):
            return m1 == m2
        default:
            return false
        }
    }
}

@Observable
final class ImportViewModel {
    var state: ImportState = .idle
    var showingPicker = false

    private let importService = MediaImportService.shared
    private let thumbnailService = ThumbnailService.shared

    func handlePickerResults(_ results: [PHPickerResult]) async {
        guard !results.isEmpty else {
            state = .idle
            return
        }

        state = .loading(progress: 0, loaded: 0, total: results.count)

        var items: [MediaItem] = []

        for (index, result) in results.enumerated() {
            do {
                var item = try await importService.loadMediaItem(from: result)

                // Generate thumbnail
                do {
                    let thumbnailURL = try await thumbnailService.generateThumbnail(for: item)
                    item.thumbnailURL = thumbnailURL
                } catch {
                    print("Thumbnail generation failed: \(error)")
                }

                items.append(item)

                let progress = Double(index + 1) / Double(results.count)
                state = .loading(progress: progress, loaded: index + 1, total: results.count)
            } catch {
                print("Failed to load media item: \(error)")
            }
        }

        if items.isEmpty {
            state = .error(message: "Failed to load any media")
        } else {
            state = .loaded(items: items)
        }
    }

    func reset() {
        state = .idle
        showingPicker = false
    }
}
