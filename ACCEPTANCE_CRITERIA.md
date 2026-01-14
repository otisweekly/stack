# Acceptance Criteria

## Overview

This document defines the acceptance criteria for every feature in Stack. A feature is not complete until ALL criteria are met and verified. Use this as your checklist before marking anything done.

---

## Phase 1: Project Setup & Core Infrastructure

### AC-1.1: Xcode Project Configuration
- [ ] Project builds without errors or warnings
- [ ] Bundle ID is `com.anthropic.stack`
- [ ] Deployment target is iOS 26.2
- [ ] Device family is iPhone only
- [ ] App launches to a blank screen without crashing

### AC-1.2: Info.plist Permissions
- [ ] `NSPhotoLibraryUsageDescription` is set with user-friendly message
- [ ] `NSPhotoLibraryAddUsageDescription` is set with user-friendly message
- [ ] App prompts for photo library permission on first import attempt

### AC-1.3: Font Setup
- [ ] Fuji font files added to project (Light, Regular, Medium, Bold, Black)
- [ ] Fonts listed in Info.plist under "Fonts provided by application"
- [ ] `Font.fujiBody` renders correctly in a test view
- [ ] All font weights render correctly (test each one)

### AC-1.4: Color System
- [ ] `Color.stackBlack` renders as pure black (#000000)
- [ ] `Color.stackWhite` renders as pure white (#FFFFFF)
- [ ] `Color.stackAccent` renders as signal orange (#009290)
- [ ] App background is pure black
- [ ] Text is pure white on black background

### AC-1.5: Dark Mode Only
- [ ] App appearance is forced to dark mode
- [ ] Changing system appearance to light mode does NOT affect app
- [ ] All UI elements remain correct in both system appearances

### AC-1.6: Basic Navigation
- [ ] Tab bar displays at bottom with liquid glass material
- [ ] Three tabs visible: Create, Library, Settings
- [ ] Tapping each tab switches content area
- [ ] Active tab shows accent color
- [ ] Inactive tabs show white at 50% opacity
- [ ] Tab bar is pill/capsule shaped

---

## Phase 2: Data Models & Services

### AC-2.1: MediaItem Model
- [ ] Can create a `MediaItem` with type `.video`
- [ ] Can create a `MediaItem` with type `.image`
- [ ] `duration` returns video duration for videos
- [ ] `duration` returns `imageDuration` (default 1.0) for images
- [ ] `formattedDuration` returns "M:SS" for videos
- [ ] `formattedDuration` returns "IMG" for images
- [ ] `aspectRatio` calculates correctly from `originalSize`

### AC-2.2: MediaLayer Model
- [ ] Can create a `MediaLayer` from a `MediaItem`
- [ ] Default position is near center (0.5 ± 0.1)
- [ ] Default size is 40% of canvas width
- [ ] `pixelFrame(in:)` converts normalized coords to pixels correctly
- [ ] `zIndex` determines layer ordering

### AC-2.3: Composition Model
- [ ] Can create empty composition with `Composition.empty()`
- [ ] Can add layers with `addLayer(_:)`
- [ ] Can remove layers with `removeLayer(id:)`
- [ ] Can update layers with `updateLayer(_:)`
- [ ] `bringToFront(layerID:)` sets highest zIndex
- [ ] `sendToBack(layerID:)` sets lowest zIndex
- [ ] `sortedStack` returns layers in zIndex order
- [ ] `calculateDuration(with:)` returns longest media duration

### AC-2.4: HapticsService
- [ ] `HapticsService.shared.light()` triggers light haptic on device
- [ ] `HapticsService.shared.medium()` triggers medium haptic on device
- [ ] `HapticsService.shared.heavy()` triggers heavy haptic on device
- [ ] `HapticsService.shared.success()` triggers success haptic on device
- [ ] `HapticsService.shared.error()` triggers error haptic on device
- [ ] Haptics work in simulator (no crash, just no feedback)

### AC-2.5: AppState
- [ ] `AppState` is `@Observable`
- [ ] `currentTab` switches between tabs
- [ ] `mediaItems` stores imported media
- [ ] `composition` stores current composition
- [ ] `reset()` clears all state

---

## Phase 3: Media Import Flow

### AC-3.1: PHPicker Presentation
- [ ] Tapping "Import Media" presents PHPicker
- [ ] PHPicker shows both videos AND photos
- [ ] Selection limit is 12 items
- [ ] Can select mix of videos and images
- [ ] Canceling picker returns to import screen without changes

### AC-3.2: Media Loading
- [ ] Selected videos load without error
- [ ] Selected images load without error
- [ ] Progress indicator shows during loading
- [ ] Progress updates as each item loads
- [ ] Loading completes within 3 seconds for 12 items (typical)

### AC-3.3: Thumbnail Generation
- [ ] Video thumbnails generate from first frame (or 0.5s)
- [ ] Image thumbnails generate from image data
- [ ] Thumbnails display at correct aspect ratio
- [ ] Thumbnails are cached in memory
- [ ] No visible delay when scrolling through thumbnails

### AC-3.4: Contact Sheet Display
- [ ] Grid displays 3 columns on iPhone
- [ ] Each cell shows thumbnail at correct aspect ratio
- [ ] Videos show duration badge (bottom-right, glass background)
- [ ] Images show "IMG" badge or photo icon
- [ ] Media type icon shows in top-left (video/photo SF Symbol)
- [ ] Selection checkbox shows in top-right

### AC-3.5: Selection Behavior
- [ ] Tapping unselected item selects it (checkbox fills with accent)
- [ ] Tapping selected item deselects it (checkbox empties)
- [ ] Selection count updates in footer
- [ ] Light haptic triggers on each selection change
- [ ] All items selected by default on first load
- [ ] Can deselect all and reselect specific items

### AC-3.6: Navigation to Canvas
- [ ] "Continue" button disabled when < 1 items selected
- [ ] "Continue" button enabled when ≥ 1 items selected
- [ ] "Continue" button uses accent color (#009290)
- [ ] Tapping "Continue" navigates to canvas
- [ ] Medium haptic triggers on "Continue"
- [ ] Selected media appears as layers on canvas

---

## Phase 3.5: Settings Tab

### AC-3.5.1: Settings Tab Structure
- [ ] Settings tab accessible from tab bar
- [ ] Tab icon is `slider.horizontal.3`
- [ ] Settings screen has two sections: Audio Mixer, Defaults

### AC-3.5.2: Audio Mixer Section
- [ ] Shows contact sheet grid of all media in composition
- [ ] Grid shows thumbnails for each media item
- [ ] Video items have volume slider below thumbnail
- [ ] Image items show thumbnail only (no audio controls)
- [ ] Volume slider range is 0% to 100%
- [ ] Muted items (0%) show mute icon overlay
- [ ] Slider uses accent color (#009290)
- [ ] Adjusting slider updates audio in real-time during preview
- [ ] Light haptic on slider change

### AC-3.5.3: Defaults Section
- [ ] Image Duration picker with options: 0.5s, 1s, 2s, 3s, 5s
- [ ] Default Canvas picker with options: 9:16, 16:9, 1:1, 4:5
- [ ] Loop Media toggle switch
- [ ] Changes persist when app is closed and reopened
- [ ] Changes apply to new imports (not existing composition)

### AC-3.5.4: Empty State
- [ ] When no composition exists, Audio Mixer shows helpful message
- [ ] Message suggests creating a composition first
- [ ] Defaults section still visible and functional

---

## Phase 4: Canvas Core

### AC-4.1: Canvas Display
- [ ] Canvas displays with correct aspect ratio (default 9:16)
- [ ] Canvas is centered in available space
- [ ] Canvas has subtle border (white at low opacity)
- [ ] Background outside canvas is pure black
- [ ] Canvas interior shows media layers

### AC-4.2: Canvas Size Selection
- [ ] Can switch between 9:16, 16:9, 1:1, 4:5
- [ ] Canvas redraws immediately on size change
- [ ] Stack reposition proportionally on size change
- [ ] Current size is indicated in UI (selected state)

### AC-4.3: Layer Display
- [ ] Each layer shows its media (thumbnail for now)
- [ ] Stack display at correct position
- [ ] Stack display at correct size
- [ ] Stack stack in correct z-order (higher zIndex on top)
- [ ] Layer corners have small radius

### AC-4.4: Layer Selection
- [ ] Tapping layer selects it
- [ ] Selected layer shows accent color border (2pt)
- [ ] Tapping canvas background deselects all
- [ ] Only one layer selected at a time
- [ ] Light haptic on selection change

### AC-4.5: Layer Dragging
- [ ] Can drag selected layer by touching and moving
- [ ] Layer moves smoothly with finger
- [ ] Layer stays within canvas bounds (or allows overflow?)
- [ ] Position updates when drag ends
- [ ] Light haptic on drag start
- [ ] Medium haptic on drag end

### AC-4.6: Layer Resizing
- [ ] Pinch gesture scales selected layer
- [ ] Scale is proportional (maintains aspect ratio)
- [ ] Minimum size enforced (e.g., 10% of canvas)
- [ ] Maximum size enforced (e.g., 150% of canvas)
- [ ] Size updates when pinch ends
- [ ] Light haptic during resize

### AC-4.7: Layer Context Menu
- [ ] Long-press on layer shows context menu
- [ ] "Bring to Front" option works
- [ ] "Send to Back" option works
- [ ] "Delete" option removes layer
- [ ] Heavy haptic on delete
- [ ] Menu dismisses on selection or tap outside

### AC-4.8: Utility Panel
- [ ] Panel slides up from bottom
- [ ] Panel has liquid glass background
- [ ] Panel has drag handle at top
- [ ] Swipe down collapses panel
- [ ] Swipe up expands panel
- [ ] Canvas size picker in panel
- [ ] Snap-to-grid toggle in panel (future)
- [ ] Loop toggle in panel

---

## Phase 5: Video Playback

### AC-5.1: Video Layer Playback
- [ ] Video layers play actual video (not just thumbnail)
- [ ] All video layers play simultaneously
- [ ] Videos loop when they reach the end
- [ ] Video playback is smooth (no stuttering)
- [ ] Videos play with audio (audible during preview)

### AC-5.2: Image Layer Display
- [ ] Image layers display the image
- [ ] Images remain static (no playback needed for preview)
- [ ] Images display at full quality within layer bounds

### AC-5.3: Playback Controls
- [ ] Play button shows when paused
- [ ] Pause button shows when playing
- [ ] Tapping play starts all videos with audio
- [ ] Tapping pause stops all videos
- [ ] Medium haptic on play/pause

### AC-5.4: Timeline Scrubber
- [ ] Scrubber shows current position
- [ ] Scrubber shows total duration (max 90 seconds)
- [ ] Dragging scrubber seeks all videos
- [ ] Time display updates during scrub
- [ ] Accent color (#009290) for scrubber knob/fill
- [ ] Selection haptic during scrubbing

### AC-5.5: Time Display
- [ ] Current time displays in M:SS format
- [ ] Total duration displays in M:SS format
- [ ] Uses monospace font
- [ ] Updates in real-time during playback

### AC-5.6: Performance
- [ ] Preview maintains 60fps with 4 video layers
- [ ] Preview maintains 30fps with 8 video layers
- [ ] Preview maintains 20fps with 12 video layers
- [ ] Audio from multiple videos plays simultaneously
- [ ] Memory usage stays under 500MB with 12 layers

### AC-5.7: Layer Overflow
- [ ] Layers can be dragged beyond canvas edges
- [ ] Overflowed portions are visually clipped
- [ ] Overflow position is preserved in composition
- [ ] Overflow is cropped correctly in export

---

## Phase 6: Export

### AC-6.1: Export Screen
- [ ] Navigating to export shows export options
- [ ] Preview of composition visible
- [ ] Resolution picker shows 1080p and 4K options
- [ ] Estimated file size displays
- [ ] Estimated size updates when resolution changes
- [ ] "Export" button prominent with accent color

### AC-6.2: Export Process
- [ ] Tapping "Export" starts export process
- [ ] Progress modal appears immediately
- [ ] Progress bar updates during export
- [ ] Percentage text updates during export
- [ ] "Cancel" button available during export
- [ ] Canceling stops export and returns to canvas

### AC-6.3: Video Composition
- [ ] Exported video has correct canvas dimensions
- [ ] All video layers appear at correct positions
- [ ] All image layers appear at correct positions
- [ ] Image layers display for their configured duration
- [ ] Video layers play their full duration (up to 90s cap)
- [ ] Layers maintain correct z-ordering
- [ ] Shorter media loops to match composition duration
- [ ] Layers that overflow canvas are cropped correctly

### AC-6.4: Audio Export
- [ ] Exported video includes audio from video layers
- [ ] Per-clip volume levels are applied correctly
- [ ] Muted clips (0% volume) produce no audio
- [ ] Multiple audio tracks are mixed together
- [ ] Audio is in sync with video
- [ ] No audio distortion or clipping

### AC-6.5: Export Quality
- [ ] 1080p export produces correct resolution
- [ ] 4K export produces correct resolution
- [ ] Video codec is H.264 or HEVC
- [ ] No visible compression artifacts at default bitrate
- [ ] Audio codec is AAC
- [ ] File size is within expected range

### AC-6.6: Save to Photos
- [ ] Export saves to Photos library automatically
- [ ] Success notification/haptic on completion
- [ ] User can find video in Photos app
- [ ] Share sheet available after export

### AC-6.7: Export Performance
- [ ] 10-second composition exports in < 15 seconds
- [ ] 30-second composition exports in < 45 seconds
- [ ] 90-second composition exports in < 90 seconds
- [ ] Export progress is accurate (not jumping)
- [ ] App remains responsive during export

### AC-6.8: Error Handling
- [ ] Export failure shows error message
- [ ] Error haptic on failure
- [ ] User can retry after failure
- [ ] Specific error messages for common issues (disk space, permissions)

---

## Phase 7: Polish & Refinement

### AC-7.1: Animations
- [ ] Tab switches animate smoothly
- [ ] Layer selection border animates in
- [ ] Utility panel slides with spring animation
- [ ] Contact sheet items fade in with stagger
- [ ] No janky or stuttering animations

### AC-7.2: Error States
- [ ] No media selected → shows empty state with message
- [ ] Permission denied → shows explanation and settings link
- [ ] Export failed → shows retry option
- [ ] All errors have appropriate haptic feedback

### AC-7.3: Loading States
- [ ] Import shows loading indicator
- [ ] Export shows progress bar
- [ ] Thumbnail generation shows placeholder
- [ ] No frozen UI during async operations

### AC-7.4: Accessibility
- [ ] All buttons have accessibility labels
- [ ] All images have accessibility descriptions
- [ ] VoiceOver can navigate entire app
- [ ] Dynamic Type scales text appropriately
- [ ] Minimum touch targets are 44x44pt

### AC-7.5: Edge Cases
- [ ] Single video works (shows warning but allows)
- [ ] 12 videos works without crash
- [ ] Very short videos (< 1s) work
- [ ] Very long videos (> 60s) work
- [ ] Portrait and landscape videos work
- [ ] Square videos work
- [ ] Large images (4K+) work
- [ ] Small images work
- [ ] Mixed portrait/landscape media works

### AC-7.6: Memory & Performance
- [ ] No memory leaks during extended use
- [ ] Memory drops when leaving canvas
- [ ] App doesn't crash on memory warning
- [ ] Battery usage is reasonable

---

## Phase 8: App Store Preparation

### AC-8.1: App Icon
- [ ] 1024x1024 icon created
- [ ] All required sizes generated
- [ ] Icon displays correctly on home screen
- [ ] Icon displays correctly in Settings

### AC-8.2: Launch Screen
- [ ] Launch screen matches app aesthetic
- [ ] No white flash on launch
- [ ] Transition to app is smooth

### AC-8.3: Screenshots
- [ ] 6.7" screenshots captured (iPhone 15 Pro Max)
- [ ] 6.1" screenshots captured (iPhone 15)
- [ ] Screenshots show key features
- [ ] Screenshots are compelling and clear

### AC-8.4: Metadata
- [ ] App name is "Stack"
- [ ] Subtitle is descriptive
- [ ] Description explains value prop
- [ ] Keywords are relevant
- [ ] Privacy policy URL is valid
- [ ] Support URL is valid

### AC-8.5: Build Validation
- [ ] Archive builds without errors
- [ ] App validates in Xcode
- [ ] No missing assets
- [ ] No capability issues
- [ ] TestFlight build works correctly

---

## User Flow Verification

### Complete Flow Test 1: Basic Composition
1. [ ] Launch app fresh
2. [ ] Navigate to Create tab
3. [ ] Tap Import Media
4. [ ] Grant photo library permission
5. [ ] Select 4 videos
6. [ ] Verify all appear in contact sheet
7. [ ] Deselect 1, verify count updates
8. [ ] Tap Continue
9. [ ] Verify all 3 selected videos on canvas
10. [ ] Drag one layer to new position
11. [ ] Pinch another layer smaller
12. [ ] Tap play, verify all videos play
13. [ ] Navigate to export
14. [ ] Select 1080p
15. [ ] Tap Export
16. [ ] Wait for completion
17. [ ] Verify video in Photos app
18. [ ] Verify all layers visible in exported video

### Complete Flow Test 2: Mixed Media
1. [ ] Select 2 videos and 2 images
2. [ ] Verify videos show duration, images show "IMG"
3. [ ] Continue to canvas
4. [ ] Play preview
5. [ ] Verify videos play, images display
6. [ ] Export
7. [ ] Verify exported video shows images for ~1 second each
8. [ ] Verify videos play full duration

### Complete Flow Test 3: Canvas Sizes
1. [ ] Create composition
2. [ ] Default is 9:16, verify tall canvas
3. [ ] Switch to 16:9, verify wide canvas
4. [ ] Switch to 1:1, verify square canvas
5. [ ] Switch to 4:5, verify portrait canvas
6. [ ] Export each size
7. [ ] Verify exported dimensions are correct

---

## Definition of Done

A feature is DONE when:

1. ✅ All acceptance criteria checked off
2. ✅ Code compiles without warnings
3. ✅ Feature works on physical device
4. ✅ Haptic feedback implemented
5. ✅ Animations are smooth (60fps)
6. ✅ No memory leaks
7. ✅ Error cases handled gracefully
8. ✅ Accessibility labels added
9. ✅ PROGRESS.md updated

---

## Bug Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| P0 - Critical | App crashes, data loss | Fix immediately, block release |
| P1 - High | Feature broken, no workaround | Fix before release |
| P2 - Medium | Feature degraded, workaround exists | Fix if time permits |
| P3 - Low | Minor issue, cosmetic | Fix in future release |

---

## How to Use This Document

### During Development
1. Before implementing a feature, read its acceptance criteria
2. Build to satisfy each criterion
3. Check off criteria as you verify them
4. Don't move on until all criteria pass

### During Review
1. Go through criteria one by one
2. Test each criterion explicitly
3. Mark any failures
4. Fix failures before marking complete

### Before Compaction
1. Update PROGRESS.md with criteria status
2. Note which criteria are passing/failing
3. Document any blockers
