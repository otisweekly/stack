import Foundation

struct AppSettings: Codable {
    var defaultImageDuration: TimeInterval = 1.0     // 0.5 - 5.0 seconds
    var defaultCanvasSize: CanvasSize = .portrait9x16
    var loopMediaByDefault: Bool = true

    // Persist to UserDefaults
    static let key = "StackAppSettings"

    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
