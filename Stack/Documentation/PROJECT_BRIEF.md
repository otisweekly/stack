# Stack - Video & Image Collage Compositor

## Project Overview

**Stack** is an iOS application for creating dynamic media collages where multiple videos and images play simultaneously in a freeform spatial arrangement. Users import batches of media, position and resize them on a canvas, adjust per-clip audio levels, and export the resulting composition as a single video file.

The app uses iOS 26's liquid glass design language with a strict black-and-white interface, letting user content be the only source of color.

---

## Vision

Create the fastest, most intuitive way to produce "living mood boards" - compositions where multiple media items play at once, creating layered, textural visual experiences. Think Instagram stories meets professional video compositing, with a minimal, editorial aesthetic.

---

## Target User

- Content creators who want to create unique, eye-catching video content
- Photographers and videographers exploring motion work
- Social media creators building mood boards and compilations
- Anyone who wants to combine multiple video moments into one composition

---

## Core Value Proposition

1. **Batch Import**: Select up to 12 videos OR images at once from the photo library
2. **Freeform Canvas**: Position and resize media anywhere on the canvas (layers can overflow edges)
3. **Per-Clip Audio**: Adjust volume levels for each video independently
4. **Real-Time Preview**: See and hear all media playing simultaneously before export
5. **One-Tap Export**: Render the final composition (up to 90 seconds) to camera roll

---

## Key Features

### MVP (Version 1.0)

1. **Batch Media Import**
   - PHPicker integration for selecting multiple videos AND images
   - Support for 1-12 media items per composition
   - Automatic thumbnail generation for contact sheet view

2. **Contact Sheet View**
   - Grid display of imported media with thumbnails
   - Duration badge for videos, "IMG" badge for images
   - Tap to select/deselect for inclusion in composition
   - Reorder via drag and drop

3. **Composition Canvas**
   - Selectable canvas ratios: 9:16 (Stories - default), 16:9 (Landscape), 1:1 (Square), 4:5 (Portrait)
   - Media appears as draggable, resizable rectangles
   - Pinch to scale, drag to position
   - **Layers can extend beyond canvas edges** (cropped in export)
   - Long-press context menu for layer ordering

4. **Media Timing**
   - **Videos**: Play their full duration, loop if shorter than composition
   - **Images**: Display for configurable duration (default 1 second, range 0.5s - 5s)
   - **Max composition duration**: 90 seconds
   - Composition duration = longest media item (capped at 90s)

5. **Audio Controls**
   - Videos play with audio during preview
   - **Per-clip volume control** via Settings tab (contact sheet grid UI)
   - Individual clips can be muted or adjusted 0-100%
   - All audio mixed in final export

6. **Playback Controls**
   - Play/pause all media simultaneously with audio
   - Scrub timeline to preview any point in composition
   - Loop mode toggle
   - Duration display showing composition length

7. **Settings Tab**
   - **Audio Mixer**: Contact sheet grid showing all clips with individual volume sliders
   - **Image Duration**: Default display time for images (applies to new imports)
   - **Default Canvas Size**: User preference for new compositions
   - **Loop Behavior**: Default loop setting

8. **Export**
   - Render to 1080p or 4K
   - Includes mixed audio from all video layers
   - Save to camera roll
   - Share sheet integration
   - No watermark

### Future Versions

- Per-layer opacity controls
- Blend modes (multiply, screen, overlay)
- Video trimming within the app
- Templates/presets for common layouts
- iCloud sync for projects

---

## Design Language

### Visual Identity

The app uses iOS 26's liquid glass with a strict black-and-white palette:

- **Background**: Pure black (`#000000`)
- **Text/Icons**: Pure white (`#FFFFFF`)
- **Accent**: Teal (`#009290`) - primary actions only
- **Surfaces**: Liquid glass (`.ultraThinMaterial`)
- **Typography**: Pangram Pangram "Fuji"

### Key UI Elements

- **Bottom Tab Bar**: Liquid glass capsule (App Store style)
- **Panels**: Liquid glass with subtle borders
- **Buttons**: Accent color for primary, white border for secondary
- **Content**: User media is the ONLY color in the interface

See `DESIGN_LANGUAGE.md` for complete specifications.

---

## Technical Constraints

- **iOS 26.2+** minimum deployment target
- **iPhone only** for MVP (iPad in future version)
- **SwiftUI** for UI layer
- **AVFoundation + Metal** for media compositing
- **No external dependencies** except system frameworks
- **Dark mode only**

---

## Success Metrics

1. Users can complete a composition in under 2 minutes
2. Export completes in under 45 seconds for 90-second compositions
3. App size under 50MB (plus font assets)
4. Memory usage stable with 12 simultaneous media layers
5. Smooth 60fps preview playback

---

## Out of Scope for MVP

- Video trimming within the app
- Filters or color grading
- Text overlays
- Animation keyframes
- Apple Watch companion
- macOS version
- Light mode
