import AVFoundation
import Combine

final class VideoPlayerManager: ObservableObject {
    private var players: [UUID: AVQueuePlayer] = [:]
    private var loopers: [UUID: AVPlayerLooper] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var timeObservers: [UUID: Any] = [:]

    @Published var isPlaying = false
    @Published var currentTime: CMTime = .zero

    func setupPlayer(for layer: MediaLayer, url: URL, loop: Bool = true) {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = layer.isMuted
        player.volume = layer.audioVolume

        if loop {
            let looper = AVPlayerLooper(player: player, templateItem: item)
            loopers[layer.id] = looper
        }

        players[layer.id] = player

        // Add time observer to first player
        if players.count == 1 {
            let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
            let observer = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.currentTime = time
            }
            timeObservers[layer.id] = observer
        }
    }

    func play() {
        players.values.forEach { $0.play() }
        isPlaying = true
    }

    func pause() {
        players.values.forEach { $0.pause() }
        isPlaying = false
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: CMTime) {
        players.values.forEach { player in
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        currentTime = time
    }

    func setVolume(_ volume: Float, for layerID: UUID) {
        players[layerID]?.volume = volume
        players[layerID]?.isMuted = volume == 0
    }

    func player(for layerID: UUID) -> AVPlayer? {
        players[layerID]
    }

    func cleanup() {
        pause()

        // Remove time observers
        for (layerID, observer) in timeObservers {
            players[layerID]?.removeTimeObserver(observer)
        }

        timeObservers.removeAll()
        players.removeAll()
        loopers.removeAll()
        cancellables.removeAll()
    }

    deinit {
        cleanup()
    }
}
