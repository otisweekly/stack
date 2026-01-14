# START HERE

## For Any Agent or Claude Instance Picking Up This Project

**Read this first. Every time. Even if you think you remember.**

---

## What Is This Project?

**Stack** is an iOS app for creating video collages where multiple videos play simultaneously in a freeform spatial arrangement. Think "living mood boards."

It shares visual DNA with **Frontier** (a photo processing app) - same cream/dark aesthetic, same tactile feel, same import patterns.

---

## Current State

**Check `PROGRESS.md` immediately** to see:
- What phase we're in
- What's been completed
- What's currently being worked on
- Any blockers or discoveries
- Next steps

```
📍 ALWAYS READ PROGRESS.md BEFORE DOING ANYTHING
```

---

## Document Map

| Priority | Document | When to Read |
|----------|----------|--------------|
| 🔴 **1** | `PROGRESS.md` | FIRST. Always. Every session. |
| 🔴 **2** | `START_HERE.md` | You're here now. |
| 🟡 **3** | `README.md` | Overview of all docs |
| 🟡 **4** | `PROJECT_BRIEF.md` | If unclear on product vision |
| 🟢 **5** | `IMPLEMENTATION_GUIDE.md` | For current phase tasks |
| 🟢 **6** | Other docs | As needed for specific work |

---

## Quick Context Restoration

If you're picking this up mid-project and need fast context:

### 1. Check Current Phase
```
Open PROGRESS.md → Find "## Current Phase"
```

### 2. Check What's Done
```
Open PROGRESS.md → Find "## Completed Work"
```

### 3. Check What's Next
```
Open PROGRESS.md → Find "## Next Steps"
```

### 4. Check for Blockers
```
Open PROGRESS.md → Find "## Blockers & Issues"
```

### 5. Review Recent Decisions
```
Open PROGRESS.md → Find "## Decision Log"
```

---

## Your Responsibilities

As an agent working on this project, you MUST:

### Before Starting Work
- [ ] Read `PROGRESS.md` completely
- [ ] Understand current phase and status
- [ ] Review any blockers or open questions

### During Work
- [ ] Update `PROGRESS.md` when you complete significant tasks
- [ ] Log any discoveries or decisions in the Decision Log
- [ ] Note any blockers immediately

### Before Conversation Ends / Compacts
- [ ] Update `PROGRESS.md` with current status
- [ ] Document what you were working on
- [ ] List clear next steps
- [ ] Note any context that would be lost

---

## Project File Structure

Once the Xcode project exists:

```
Stack/
├── Documentation/          ← These docs should live here
│   ├── START_HERE.md
│   ├── PROGRESS.md
│   ├── README.md
│   └── ... other docs
├── App/
├── Models/
├── ViewModels/
├── Views/
├── Services/
├── Compositor/
├── Extensions/
└── Resources/
```

---

## Key Technical Facts

- **Platform**: iOS 16+, iPhone only
- **UI Framework**: SwiftUI with @Observable
- **Video**: AVFoundation + Metal
- **Dependencies**: None (system frameworks only)
- **Architecture**: MVVM + Services

---

## Emergency Context

If you're completely lost:

1. **Product**: Video collage app - import videos, arrange them freely on canvas, all play at once, export as single video

2. **Visual Style**: Dark backgrounds (#1A1A1A), cream panels (#F5F2EB), orange accents (#E85D04), lots of haptics

3. **Core Flow**: Import → Contact Sheet → Canvas (arrange/play) → Export

4. **Hard Part**: The video compositor - Metal for preview, AVFoundation for export

---

## Contact / Ownership

- **Project Owner**: Otis
- **Sister App**: Frontier (photo processing)
- **Design System**: Shared with Frontier

---

## Remember

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   📍 READ PROGRESS.md BEFORE EVERY SESSION              │
│                                                         │
│   📝 UPDATE PROGRESS.md BEFORE EVERY COMPACTION         │
│                                                         │
│   🚨 LOG DISCOVERIES AND DECISIONS IMMEDIATELY          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```
