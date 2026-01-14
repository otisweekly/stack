import SwiftUI

@Observable
final class AppState {
    var currentTab: Tab = .create
    var currentScreen: Screen = .import_
    var mediaItems: [MediaItem] = []
    var composition: Composition?
    var selectedLayerID: UUID?
    var isExporting = false
    var settings: AppSettings = AppSettings.load()

    enum Tab: String, CaseIterable {
        case create
        case library
        case settings

        var icon: String {
            switch self {
            case .create: return "plus.square"
            case .library: return "square.stack"
            case .settings: return "gearshape"
            }
        }

        var label: String {
            switch self {
            case .create: return "Create"
            case .library: return "Library"
            case .settings: return "Settings"
            }
        }
    }

    enum Screen {
        case import_
        case contactSheet
        case canvas
        case export
    }

    func reset() {
        currentScreen = .import_
        mediaItems = []
        composition = nil
        selectedLayerID = nil
        isExporting = false
    }

    func mediaItem(for layer: MediaLayer) -> MediaItem? {
        mediaItems.first { $0.id == layer.mediaID }
    }

    func saveSettings() {
        settings.save()
    }

    // Audio helpers for Settings tab
    func videoLayers() -> [MediaLayer] {
        composition?.layers.filter { $0.mediaType == .video } ?? []
    }

    func setVolume(_ volume: Float, for layerID: UUID) {
        composition?.updateAudioVolume(layerID, volume: volume)
    }
}
