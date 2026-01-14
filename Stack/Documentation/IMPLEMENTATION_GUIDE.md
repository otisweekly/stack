# Implementation Guide

## Overview

This guide provides a step-by-step implementation plan for building Stack. Each phase builds on the previous, with clear milestones and testable outcomes.

---

## Phase 1: Project Setup & Core Infrastructure

**Duration**: 1-2 hours  
**Milestone**: App launches with basic navigation

### Tasks

1. **Create Xcode Project**
   ```
   - iOS App template
   - SwiftUI interface
   - Swift language
   - Bundle ID: com.anthropic.stack
   - Deployment target: iOS 16.0
   - Device: iPhone only
   ```

2. **Configure Project Settings**
   ```
   Info.plist additions:
   - NSPhotoLibraryUsageDescription: "Stack needs access to your photos to import videos for your compositions."
   - NSPhotoLibraryAddUsageDescription: "Stack needs permission to save exported videos to your photo library."
   ```

3. **Create Folder Structure**
   ```
   Create all folders as defined in TECHNICAL_ARCHITECTURE.md
   ```

4. **Implement Design System**
   ```swift
   // Create Extensions/Color+Theme.swift
   // Create Extensions/Font+Theme.swift
   // Create spacing and corner radius constants
   ```

5. **Create App Entry Point**
   ```swift
   // StackApp.swift
   @main
   struct StackApp: App {
       @State private var appState = AppState()
       
       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environment(appState)
           }
       }
   }
   ```

6. **Implement Basic Navigation**
   ```swift
   // Create Screen enum
   enum Screen {
       case import_
       case contactSheet
       case canvas
       case export
   }
   
   // ContentView with navigation
   struct ContentView: View {
       @Environment(AppState.self) var appState
       
       var body: some View {
           switch appState.currentScreen {
           case .import_:
               ImportView()
           case .contactSheet:
               ContactSheetView()
           case .canvas:
               CanvasView()
           case .export:
               ExportView()
           }
       }
   }
   ```

### Verification
- [ ] App builds and runs
- [ ] Can navigate between placeholder screens
- [ ] Theme colors render correctly

---

## Phase 2: Data Models & Services Foundation

**Duration**: 2-3 hours  
**Milestone**: Models compile, services instantiate

### Tasks

1. **Implement Core Models**
   ```
   Create all models from DATA_MODELS.md:
   - VideoClip.swift
   - VideoLayer.swift
   - Composition.swift
   - CanvasSize.swift
   - ExportResolution.swift
   - ExportSettings.swift
   ```

2. **Create Service Protocols**
   ```swift
   // Services/Protocols/MediaImporting.swift
   protocol MediaImporting {
       func requestAuthorization() async -> Bool
       func importVideos(limit: Int) async throws -> [VideoClip]
   }
   
   // Services/Protocols/ThumbnailGenerating.swift
   protocol ThumbnailGenerating {
       func generateThumbnail(for clip: VideoClip) async throws -> URL
       func generateThumbnails(for clips: [VideoClip]) async throws -> [UUID: URL]
   }
   ```

3. **Implement HapticsService**
   ```swift
   // Services/HapticsService.swift
   import UIKit
   
   final class HapticsService {
       static let shared = HapticsService()
       
       private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
       private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
       private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
       private let selectionGenerator = UISelectionFeedbackGenerator()
       private let notificationGenerator = UINotificationFeedbackGenerator()
       
       private init() {
           prepareAll()
       }
       
       func prepareAll() {
           lightGenerator.prepare()
           mediumGenerator.prepare()
           heavyGenerator.prepare()
           selectionGenerator.prepare()
       }
       
       func light() { lightGenerator.impactOccurred() }
       func medium() { mediumGenerator.impactOccurred() }
       func heavy() { heavyGenerator.impactOccurred() }
       func selection() { selectionGenerator.selectionChanged() }
       func success() { notificationGenerator.notificationOccurred(.success) }
       func warning() { notificationGenerator.notificationOccurred(.warning) }
       func error() { notificationGenerator.notificationOccurred(.error) }
   }
   ```

4. **Create AppState**
   ```swift
   // App/AppState.swift
   @Observable
   final class AppState {
       var currentScreen: Screen = .import_
       var clips: [VideoClip] = []
       var composition: Composition?
       var selectedLayerID: UUID?
       var isExporting = false
       
       func reset() {
           currentScreen = .import_
           clips = []
           composition = nil
           selectedLayerID = nil
           isExporting = false
       }
   }
   ```

### Verification
- [ ] All models compile without errors
- [ ] Can create instances of each model
- [ ] HapticsService triggers haptics on device

---

## Phase 3: Media Import Flow

**Duration**: 3-4 hours  
**Milestone**: Can select videos from library, see thumbnails in grid

### Tasks

1. **Implement MediaImportService**
   ```swift
   // Services/MediaImportService.swift
   import Photos
   import PhotosUI
   import SwiftUI
   
   final class MediaImportService: MediaImporting {
       func requestAuthorization() async -> Bool {
           let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
           return status == .authorized || status == .limited
       }
       
       func loadVideoClip(from result: PHPickerResult) async throws -> VideoClip {
           // Implementation using PHPickerResult
       }
   }
   ```

2. **Create PHPicker Wrapper**
   ```swift
   // Views/Import/VideoPicker.swift
   struct VideoPicker: UIViewControllerRepresentable {
       let selectionLimit: Int
       let onSelection: ([PHPickerResult]) -> Void
       
       func makeUIViewController(context: Context) -> PHPickerViewController {
           var config = PHPickerConfiguration(photoLibrary: .shared())
           config.filter = .videos
           config.selectionLimit = selectionLimit
           config.preferredAssetRepresentationMode = .current
           
           let picker = PHPickerViewController(configuration: config)
           picker.delegate = context.coordinator
           return picker
       }
       
       // ... Coordinator implementation
   }
   ```

3. **Implement ThumbnailService**
   ```swift
   // Services/ThumbnailService.swift
   import AVFoundation
   import UIKit
   
   final class ThumbnailService: ThumbnailGenerating {
       private let thumbnailSize = CGSize(width: 200, height: 356) // 9:16
       
       func generateThumbnail(for clip: VideoClip) async throws -> URL {
           let asset = AVAsset(url: clip.url)
           let generator = AVAssetImageGenerator(asset: asset)
           generator.appliesPreferredTrackTransform = true
           generator.maximumSize = thumbnailSize
           
           let time = CMTime(seconds: 0.5, preferredTimescale: 600)
           let cgImage = try await generator.image(at: time).image
           
           let image = UIImage(cgImage: cgImage)
           let data = image.jpegData(compressionQuality: 0.8)!
           
           let url = thumbnailURL(for: clip.id)
           try data.write(to: url)
           
           return url
       }
       
       private func thumbnailURL(for id: UUID) -> URL {
           FileManager.default.temporaryDirectory
               .appendingPathComponent("thumb_\(id.uuidString).jpg")
       }
   }
   ```

4. **Implement ImportViewModel**
   ```swift
   // ViewModels/ImportViewModel.swift
   @Observable
   final class ImportViewModel {
       var state: ImportState = .idle
       var showingPicker = false
       
       private let importService: MediaImportService
       private let thumbnailService: ThumbnailService
       
       init(importService: MediaImportService = .init(),
            thumbnailService: ThumbnailService = .init()) {
           self.importService = importService
           self.thumbnailService = thumbnailService
       }
       
       func handlePickerResults(_ results: [PHPickerResult]) async {
           state = .loading(progress: 0)
           
           var clips: [VideoClip] = []
           for (index, result) in results.enumerated() {
               do {
                   var clip = try await importService.loadVideoClip(from: result)
                   clip.thumbnailURL = try await thumbnailService.generateThumbnail(for: clip)
                   clips.append(clip)
                   
                   let progress = Double(index + 1) / Double(results.count)
                   state = .loading(progress: progress)
               } catch {
                   print("Failed to load clip: \(error)")
               }
           }
           
           state = .loaded(clips: clips)
       }
   }
   ```

5. **Build ImportView**
   ```swift
   // Views/Import/ImportView.swift
   struct ImportView: View {
       @Environment(AppState.self) var appState
       @State private var viewModel = ImportViewModel()
       
       var body: some View {
           VStack(spacing: Spacing.lg) {
               Spacer()
               
               Image(systemName: "video.badge.plus")
                   .font(.system(size: 64))
                   .foregroundColor(.textSecondary)
               
               Text("Add Videos")
                   .font(.displayMedium)
                   .foregroundColor(.textPrimary)
               
               Text("Select 2-12 videos to begin")
                   .font(.bodyMedium)
                   .foregroundColor(.textSecondary)
               
               PrimaryButton(title: "Import Videos") {
                   HapticsService.shared.medium()
                   viewModel.showingPicker = true
               }
               .padding(.horizontal, Spacing.xl)
               
               Spacer()
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .background(Color.backgroundPrimary)
           .sheet(isPresented: $viewModel.showingPicker) {
               VideoPicker(selectionLimit: 12) { results in
                   Task {
                       await viewModel.handlePickerResults(results)
                   }
               }
           }
           .onChange(of: viewModel.state) { _, newState in
               if case .loaded(let clips) = newState {
                   appState.clips = clips
                   appState.currentScreen = .contactSheet
               }
           }
       }
   }
   ```

6. **Build ContactSheetView**
   ```swift
   // Views/Import/ContactSheetView.swift
   struct ContactSheetView: View {
       @Environment(AppState.self) var appState
       @State private var selectedIDs: Set<UUID> = []
       
       private let columns = [
           GridItem(.flexible(), spacing: Spacing.xs),
           GridItem(.flexible(), spacing: Spacing.xs),
           GridItem(.flexible(), spacing: Spacing.xs)
       ]
       
       var body: some View {
           NavigationStack {
               ScrollView {
                   LazyVGrid(columns: columns, spacing: Spacing.xs) {
                       ForEach(appState.clips) { clip in
                           ThumbnailCell(
                               clip: clip,
                               isSelected: selectedIDs.contains(clip.id)
                           ) {
                               toggleSelection(clip.id)
                           }
                       }
                   }
                   .padding(Spacing.xs)
               }
               .background(Color.backgroundPrimary)
               .navigationTitle("Contact Sheet")
               .navigationBarTitleDisplayMode(.inline)
               .toolbar {
                   ToolbarItem(placement: .navigationBarLeading) {
                       Button("Back") {
                           appState.currentScreen = .import_
                       }
                   }
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button("Done") {
                           createComposition()
                       }
                       .disabled(selectedIDs.count < 2)
                   }
               }
               .safeAreaInset(edge: .bottom) {
                   footerView
               }
           }
           .onAppear {
               // Select all by default
               selectedIDs = Set(appState.clips.map(\.id))
           }
       }
       
       private var footerView: some View {
           VStack(spacing: Spacing.md) {
               Text("\(selectedIDs.count) videos selected")
                   .font(.bodyMedium)
                   .foregroundColor(.textSecondary)
               
               PrimaryButton(title: "Continue to Canvas") {
                   createComposition()
               }
               .disabled(selectedIDs.count < 2)
           }
           .padding(Spacing.md)
           .background(Color.backgroundSecondary)
       }
       
       private func toggleSelection(_ id: UUID) {
           HapticsService.shared.light()
           if selectedIDs.contains(id) {
               selectedIDs.remove(id)
           } else {
               selectedIDs.insert(id)
           }
       }
       
       private func createComposition() {
           let selectedClips = appState.clips.filter { selectedIDs.contains($0.id) }
           var composition = Composition.empty()
           
           for (index, clip) in selectedClips.enumerated() {
               let layer = VideoLayer.from(clip: clip, zIndex: index)
               composition.addLayer(layer)
           }
           
           appState.composition = composition
           appState.currentScreen = .canvas
           HapticsService.shared.success()
       }
   }
   ```

### Verification
- [ ] PHPicker presents and allows video selection
- [ ] Selected videos appear in contact sheet with thumbnails
- [ ] Can select/deselect videos
- [ ] Continue button creates composition and navigates to canvas

---

## Phase 4: Canvas Core - Layout & Gestures

**Duration**: 4-5 hours  
**Milestone**: Videos render on canvas, can drag and resize

### Tasks

1. **Implement CompositionViewModel**
   ```swift
   // ViewModels/CompositionViewModel.swift
   @Observable
   final class CompositionViewModel {
       var composition: Composition
       var clips: [VideoClip]
       var selectedLayerID: UUID?
       var isPlaying = false
       var currentTime: CMTime = .zero
       
       init(composition: Composition, clips: [VideoClip]) {
           self.composition = composition
           self.clips = clips
       }
       
       func clip(for layer: VideoLayer) -> VideoClip? {
           clips.first { $0.id == layer.clipID }
       }
       
       func selectLayer(_ id: UUID?) {
           selectedLayerID = id
           HapticsService.shared.selection()
       }
       
       func updateLayerPosition(_ id: UUID, position: CGPoint) {
           guard var layer = composition.layers.first(where: { $0.id == id }) else { return }
           layer.position = position
           composition.updateLayer(layer)
       }
       
       func updateLayerSize(_ id: UUID, size: CGSize) {
           guard var layer = composition.layers.first(where: { $0.id == id }) else { return }
           layer.size = size
           composition.updateLayer(layer)
       }
       
       func bringToFront(_ id: UUID) {
           composition.bringToFront(layerID: id)
           HapticsService.shared.medium()
       }
       
       func sendToBack(_ id: UUID) {
           composition.sendToBack(layerID: id)
           HapticsService.shared.medium()
       }
       
       func deleteLayer(_ id: UUID) {
           composition.removeLayer(id: id)
           if selectedLayerID == id {
               selectedLayerID = nil
           }
           HapticsService.shared.heavy()
       }
   }
   ```

2. **Build CanvasView**
   ```swift
   // Views/Canvas/CanvasView.swift
   struct CanvasView: View {
       @Environment(AppState.self) var appState
       @State private var viewModel: CompositionViewModel?
       @State private var showingUtilityPanel = false
       
       var body: some View {
           GeometryReader { geometry in
               ZStack {
                   Color.backgroundPrimary
                       .ignoresSafeArea()
                   
                   if let vm = viewModel {
                       VStack(spacing: 0) {
                           // Canvas area
                           canvasArea(in: geometry.size, viewModel: vm)
                           
                           // Playback controls
                           PlaybackControlsView(viewModel: vm)
                           
                           // Utility panel
                           if showingUtilityPanel {
                               UtilityPanelView(
                                   composition: Binding(
                                       get: { vm.composition },
                                       set: { vm.composition = $0 }
                                   ),
                                   isExpanded: $showingUtilityPanel
                               )
                               .transition(.slideUp)
                           }
                       }
                   }
               }
           }
           .navigationTitle("Canvas")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .navigationBarLeading) {
                   Button("Back") {
                       appState.currentScreen = .contactSheet
                   }
               }
               ToolbarItem(placement: .navigationBarTrailing) {
                   Button("Export") {
                       appState.currentScreen = .export
                   }
               }
           }
           .onAppear {
               if let composition = appState.composition {
                   viewModel = CompositionViewModel(
                       composition: composition,
                       clips: appState.clips
                   )
               }
           }
       }
       
       @ViewBuilder
       private func canvasArea(in containerSize: CGSize, viewModel: CompositionViewModel) -> some View {
           let canvasSize = viewModel.composition.canvasSize.fittedSize(
               in: CGSize(
                   width: containerSize.width - Spacing.lg * 2,
                   height: containerSize.height * 0.6
               )
           )
           
           ZStack {
               // Canvas background
               Rectangle()
                   .fill(Color.backgroundSecondary)
                   .frame(width: canvasSize.width, height: canvasSize.height)
                   .overlay(
                       Rectangle()
                           .stroke(Color.white.opacity(0.2), lineWidth: 1)
                   )
               
               // Video layers
               ForEach(viewModel.composition.sortedStack) { layer in
                   if let clip = viewModel.clip(for: layer) {
                       VideoLayerView(
                           layer: layer,
                           clip: clip,
                           canvasSize: canvasSize,
                           isSelected: viewModel.selectedLayerID == layer.id,
                           onSelect: { viewModel.selectLayer(layer.id) },
                           onPositionChange: { viewModel.updateLayerPosition(layer.id, position: $0) },
                           onSizeChange: { viewModel.updateLayerSize(layer.id, size: $0) }
                       )
                   }
               }
           }
           .frame(width: canvasSize.width, height: canvasSize.height)
           .contentShape(Rectangle())
           .onTapGesture {
               viewModel.selectLayer(nil)
           }
       }
   }
   ```

3. **Build VideoLayerView with Gestures**
   ```swift
   // Views/Canvas/VideoLayerView.swift
   struct VideoLayerView: View {
       let layer: VideoLayer
       let clip: VideoClip
       let canvasSize: CGSize
       let isSelected: Bool
       let onSelect: () -> Void
       let onPositionChange: (CGPoint) -> Void
       let onSizeChange: (CGSize) -> Void
       
       @State private var dragOffset: CGSize = .zero
       @State private var currentScale: CGFloat = 1.0
       
       private var pixelFrame: CGRect {
           layer.pixelFrame(in: canvasSize)
       }
       
       var body: some View {
           ZStack {
               // Video thumbnail (placeholder for actual video)
               AsyncImage(url: clip.thumbnailURL) { image in
                   image
                       .resizable()
                       .aspectRatio(contentMode: .fill)
               } placeholder: {
                   Color.backgroundTertiary
               }
               .frame(width: pixelFrame.width * currentScale,
                      height: pixelFrame.height * currentScale)
               .clipped()
               .cornerRadius(CornerRadius.sm)
               
               // Selection border
               if isSelected {
                   RoundedRectangle(cornerRadius: CornerRadius.sm)
                       .stroke(Color.accentPrimary, lineWidth: 2)
                       .frame(width: pixelFrame.width * currentScale,
                              height: pixelFrame.height * currentScale)
                   
                   // Resize handles
                   ResizeHandlesView(
                       frameSize: CGSize(
                           width: pixelFrame.width * currentScale,
                           height: pixelFrame.height * currentScale
                       )
                   )
               }
           }
           .position(
               x: layer.position.x * canvasSize.width + dragOffset.width,
               y: layer.position.y * canvasSize.height + dragOffset.height
           )
           .gesture(tapGesture)
           .gesture(dragGesture)
           .gesture(magnificationGesture)
           .zIndex(Double(layer.zIndex))
       }
       
       private var tapGesture: some Gesture {
           TapGesture()
               .onEnded {
                   onSelect()
               }
       }
       
       private var dragGesture: some Gesture {
           DragGesture()
               .onChanged { value in
                   dragOffset = value.translation
               }
               .onEnded { value in
                   let newPosition = CGPoint(
                       x: layer.position.x + value.translation.width / canvasSize.width,
                       y: layer.position.y + value.translation.height / canvasSize.height
                   )
                   onPositionChange(newPosition)
                   dragOffset = .zero
                   HapticsService.shared.light()
               }
       }
       
       private var magnificationGesture: some Gesture {
           MagnificationGesture()
               .onChanged { value in
                   currentScale = value
               }
               .onEnded { value in
                   let newSize = CGSize(
                       width: layer.size.width * value,
                       height: layer.size.height * value
                   )
                   onSizeChange(newSize)
                   currentScale = 1.0
                   HapticsService.shared.light()
               }
       }
   }
   ```

4. **Build Playback Controls (Placeholder)**
   ```swift
   // Views/Canvas/PlaybackControlsView.swift
   struct PlaybackControlsView: View {
       @Bindable var viewModel: CompositionViewModel
       
       var body: some View {
           VStack(spacing: Spacing.sm) {
               // Transport controls
               HStack(spacing: Spacing.xl) {
                   Button(action: { /* Previous */ }) {
                       Image(systemName: "backward.fill")
                   }
                   
                   Button(action: { viewModel.isPlaying.toggle() }) {
                       Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                           .font(.title)
                   }
                   
                   Button(action: { /* Next */ }) {
                       Image(systemName: "forward.fill")
                   }
               }
               .foregroundColor(.textPrimary)
               
               // Timeline
               HStack {
                   Text(viewModel.currentTime.displayString)
                       .font(.mono)
                   
                   Slider(value: .constant(0.5))
                       .tint(.accentPrimary)
                   
                   Text("0:30")
                       .font(.mono)
               }
               .foregroundColor(.textSecondary)
               .padding(.horizontal, Spacing.md)
           }
           .padding(Spacing.md)
           .background(Color.backgroundSecondary)
       }
   }
   ```

### Verification
- [ ] Canvas renders with correct aspect ratio
- [ ] Video layers appear at correct positions
- [ ] Can select layers by tapping
- [ ] Can drag layers to reposition
- [ ] Can pinch to resize layers
- [ ] Selection border appears on selected layer

---

## Phase 5: Video Playback

**Duration**: 4-5 hours  
**Milestone**: All videos play simultaneously on canvas

### Tasks

1. **Create VideoPlayerManager**
   ```swift
   // Services/VideoPlayerManager.swift
   import AVFoundation
   import Combine
   
   final class VideoPlayerManager: ObservableObject {
       private var players: [UUID: AVPlayer] = [:]
       private var loopers: [UUID: AVPlayerLooper] = [:]
       private var cancellables = Set<AnyCancellable>()
       
       @Published var isPlaying = false
       @Published var currentTime: CMTime = .zero
       
       func setupPlayer(for layer: VideoLayer, url: URL) {
           let item = AVPlayerItem(url: url)
           let player = AVQueuePlayer(playerItem: item)
           let looper = AVPlayerLooper(player: player, templateItem: item)
           
           players[layer.id] = player
           loopers[layer.id] = looper
       }
       
       func play() {
           players.values.forEach { $0.play() }
           isPlaying = true
       }
       
       func pause() {
           players.values.forEach { $0.pause() }
           isPlaying = false
       }
       
       func seek(to time: CMTime) {
           players.values.forEach { $0.seek(to: time) }
           currentTime = time
       }
       
       func player(for layerID: UUID) -> AVPlayer? {
           players[layerID]
       }
       
       func cleanup() {
           pause()
           players.removeAll()
           loopers.removeAll()
       }
   }
   ```

2. **Create VideoPlayerView (AVPlayer wrapper)**
   ```swift
   // Views/Canvas/VideoPlayerView.swift
   import SwiftUI
   import AVKit
   
   struct VideoPlayerView: UIViewRepresentable {
       let player: AVPlayer
       
       func makeUIView(context: Context) -> PlayerUIView {
           PlayerUIView(player: player)
       }
       
       func updateUIView(_ uiView: PlayerUIView, context: Context) {
           uiView.player = player
       }
   }
   
   class PlayerUIView: UIView {
       var player: AVPlayer? {
           didSet {
               playerLayer.player = player
           }
       }
       
       private var playerLayer: AVPlayerLayer {
           layer as! AVPlayerLayer
       }
       
       override class var layerClass: AnyClass {
           AVPlayerLayer.self
       }
       
       init(player: AVPlayer) {
           super.init(frame: .zero)
           self.player = player
           playerLayer.videoGravity = .resizeAspectFill
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
   }
   ```

3. **Update VideoLayerView to use AVPlayer**
   ```swift
   // Update VideoLayerView to accept optional AVPlayer
   // Replace AsyncImage with VideoPlayerView when player is available
   ```

4. **Integrate PlayerManager with CanvasView**
   ```swift
   // Add @StateObject private var playerManager = VideoPlayerManager()
   // Setup players in onAppear
   // Wire up play/pause/seek controls
   ```

### Verification
- [ ] Videos play simultaneously
- [ ] Play/pause affects all videos
- [ ] Videos loop continuously
- [ ] Seeking works across all videos

---

## Phase 6: Video Compositing & Export

**Duration**: 5-6 hours  
**Milestone**: Can export composition as video file

### Tasks

1. **Implement StackCompositor**
   ```swift
   // Compositor/StackCompositor.swift
   import AVFoundation
   import CoreImage
   
   final class StackCompositor: NSObject, AVVideoCompositing {
       // See COMPOSITOR_SPECIFICATIONS.md for full implementation
   }
   ```

2. **Implement ExportService**
   ```swift
   // Services/ExportService.swift
   import AVFoundation
   import Photos
   
   final class ExportService {
       func export(
           composition: Composition,
           clips: [VideoClip],
           settings: ExportSettings,
           progress: @escaping (Double) -> Void
       ) async throws -> URL {
           // Build AVMutableComposition
           // Configure video composition with StackCompositor
           // Export with AVAssetExportSession
           // Save to Photos library
       }
   }
   ```

3. **Build ExportView**
   ```swift
   // Views/Export/ExportView.swift
   // Resolution selector
   // Estimated file size
   // Export button with progress
   ```

4. **Build ExportProgressView**
   ```swift
   // Views/Export/ExportProgressView.swift
   // Modal with progress bar
   // Cancel button
   // Success/failure states
   ```

### Verification
- [ ] Export completes without errors
- [ ] Output video contains all layers at correct positions
- [ ] Video saves to camera roll
- [ ] Progress updates during export

---

## Phase 7: Polish & Refinement

**Duration**: 3-4 hours  
**Milestone**: Production-ready app

### Tasks

1. **Error Handling**
   - Add proper error states to all views
   - Implement error alerts
   - Handle edge cases (no videos, permission denied, etc.)

2. **Loading States**
   - Add loading indicators for import
   - Add skeleton views during thumbnail generation
   - Add progress for export

3. **Animations**
   - Implement staggered thumbnail appearance
   - Add spring animations for layer selection
   - Smooth transitions between screens

4. **Accessibility**
   - Add VoiceOver labels
   - Support Dynamic Type
   - Respect Reduce Motion

5. **Performance Optimization**
   - Profile memory usage
   - Optimize thumbnail caching
   - Ensure 60fps preview playback

6. **Final Testing**
   - Test with 2 videos (minimum)
   - Test with 12 videos (maximum)
   - Test various video formats and sizes
   - Test on multiple device sizes

### Verification
- [ ] No crashes during normal usage
- [ ] Smooth animations throughout
- [ ] VoiceOver works correctly
- [ ] Export completes for all test cases

---

## Phase 8: App Store Preparation

**Duration**: 2-3 hours  
**Milestone**: Ready for submission

### Tasks

1. **App Icon**
   - Create 1024×1024 app icon
   - Generate all required sizes

2. **Screenshots**
   - Capture for iPhone 15 Pro Max
   - Capture for iPhone 15
   - Create App Store preview video

3. **Metadata**
   - Write App Store description
   - Prepare keywords
   - Set up privacy policy URL

4. **Final Build**
   - Archive release build
   - Validate with App Store Connect
   - Submit for review
