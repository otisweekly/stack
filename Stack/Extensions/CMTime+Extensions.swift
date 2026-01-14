import AVFoundation

extension CMTime {
    var displayString: String {
        guard isValid && !isIndefinite else { return "--:--" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

extension TimeInterval {
    var displayString: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    var formattedDuration: String {
        if self < 1 {
            return "\(Int(self * 1000))ms"
        } else {
            return "\(Int(self))s"
        }
    }
}
