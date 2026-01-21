import SwiftUI

/// Global application state using @Observable
@Observable
final class AppState {
    /// Current navigation screen
    var currentScreen: Screen = .importMedia

    /// Currently selected tab in the tab bar
    var selectedTab: StackTabBar.Tab = .create

    /// Imported media clips
    var clips: [VideoClip] = []

    /// Current composition being edited
    var composition: Composition?

    /// Currently selected layer ID on the canvas
    var selectedLayerID: UUID?

    /// Export in progress flag
    var isExporting = false

    /// Export progress (0.0 to 1.0)
    var exportProgress: Double = 0

    /// Default image duration for static images
    var defaultImageDuration: TimeInterval = 1.0

    /// Reset the app state for a new composition
    func reset() {
        currentScreen = .importMedia
        clips = []
        composition = nil
        selectedLayerID = nil
        isExporting = false
        exportProgress = 0
    }

    /// Navigate to a screen
    func navigate(to screen: Screen) {
        withAnimation(.standard) {
            currentScreen = screen
        }
    }

    /// Get clip by ID
    func clip(for id: UUID) -> VideoClip? {
        clips.first { $0.id == id }
    }

    /// Get clip for a layer
    func clip(for layer: VideoLayer) -> VideoClip? {
        clip(for: layer.clipID)
    }
}
