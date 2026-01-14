# Claude Code Instructions

## Mandatory Workflow for This Project

These instructions are **non-negotiable**. Follow them exactly.

---

## On Every Session Start

```bash
# STEP 1: Read the orientation doc
cat Documentation/START_HERE.md

# STEP 2: Read the progress file
cat Documentation/PROGRESS.md

# STEP 3: Understand current state before doing ANYTHING
```

Do not write any code until you have completed these steps.

---

## During Work

### When You Complete a Task

Update `PROGRESS.md`:

```markdown
## Completed Work
- [x] Task you just finished

## Currently Working On
- [ ] Next task
```

### When You Make a Decision

Update `PROGRESS.md`:

```markdown
## Decision Log
| [Today's Date] | What you decided | Why you decided it |
```

### When You Discover Something Important

Update `PROGRESS.md`:

```markdown
## Discovery Log
| [Today's Date] | What you found | How it affects the project |
```

### When You Hit a Blocker

Update `PROGRESS.md`:

```markdown
## Blockers & Issues
### Active Blockers
- Description of blocker and what's needed to resolve it
```

---

## Before Conversation Ends or Compacts

**This is critical. Do this EVERY time.**

### Step 1: Update Session Log

```markdown
## Session Log
### Latest Session
Date: [Today's date and time]
Agent: Claude Code
Duration: [Approximate time spent]
Work Done: 
- Bullet list of what you accomplished
- Be specific about files created/modified
Stopped Because: [Why the session is ending]
Next Steps:
- Exactly what the next agent should do
- Include file names and function names if relevant
```

### Step 2: Update Files Changed

```markdown
## Files Changed Recently
- path/to/file1.swift - Created/Modified - Brief description
- path/to/file2.swift - Created/Modified - Brief description
```

### Step 3: Update Quick Status

```markdown
## Quick Status Check
1. What phase? [Current phase]
2. What's done? [Summary]
3. What's next? [Immediate next task]
4. Any blockers? [Yes/No + brief description]
5. Anything weird? [Yes/No + brief description]
```

### Step 4: Move Previous Session

```markdown
### Previous Sessions
[Move the old "Latest Session" content here]
```

---

## Progress Update Template

Copy and fill this out before compaction:

```markdown
---
## PROGRESS UPDATE - [DATE]

### Session Summary
- Duration: X hours
- Phase: [Current phase number and name]
- Status: [In Progress / Blocked / Complete]

### Completed This Session
- [ ] Task 1
- [ ] Task 2

### Files Created/Modified
- `path/to/file.swift` - [Created/Modified] - [What it does]

### Decisions Made
- Decision: [What]
- Rationale: [Why]

### Discoveries
- Found that [X] because [Y]

### Blockers
- [None / Description of blocker]

### Next Steps (for next agent)
1. First thing to do
2. Second thing to do
3. Third thing to do

### Context That Would Be Lost
- [Any important context not captured elsewhere]
---
```

---

## File Organization

### Where Docs Live

```
Stack/
├── Documentation/           ← All .md files go here
│   ├── START_HERE.md       ← Agent orientation (read first)
│   ├── PROGRESS.md         ← Living status doc (read second)
│   ├── CLAUDE_CODE_INSTRUCTIONS.md  ← This file
│   ├── README.md
│   ├── PROJECT_BRIEF.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── DATA_MODELS.md
│   ├── UI_SPECIFICATIONS.md
│   ├── IMPLEMENTATION_GUIDE.md
│   ├── COMPOSITOR_SPECIFICATIONS.md
│   └── FRONTIER_PATTERNS.md
├── App/
├── Models/
└── ... (rest of project)
```

### When Creating the Project

1. Create the Xcode project first
2. Create a `Documentation/` folder in the project root
3. Copy all these .md files into that folder
4. Add the folder to Xcode (as a folder reference, not a group)

---

## Code Style Rules

### Swift

- Use `@Observable` not `@ObservableObject`
- Use `async/await` not completion handlers
- Use SwiftUI, not UIKit (except for AVPlayerLayer wrapper)
- No external dependencies
- Follow Apple's Swift API Design Guidelines

### Naming

- Views: `ThingView`
- ViewModels: `ThingViewModel`
- Services: `ThingService`
- Models: `Thing` (no suffix)
- Extensions: `Type+Category.swift`

### Comments

- Comment the "why", not the "what"
- Use `// MARK: -` for section organization
- Document public APIs with `///`

---

## Testing Your Work

After implementing something, verify it works:

### Phase 1 Checks
```swift
// App should launch and show import screen
// Theme colors should be correct
```

### Phase 2 Checks
```swift
// Models should compile
// Can create instances in playground/preview
```

### Phase 3 Checks
```swift
// PHPicker should present
// Selected videos should appear in grid
```

### Phase 4 Checks
```swift
// Canvas should display
// Stack should drag and resize
```

### Phase 5 Checks
```swift
// Videos should play simultaneously
// Controls should work
```

### Phase 6 Checks
```swift
// Export should complete
// Video should appear in Photos
```

---

## Common Mistakes to Avoid

### Don't
- Start coding without reading PROGRESS.md
- End session without updating PROGRESS.md
- Make decisions without logging them
- Leave blockers undocumented
- Assume the next agent knows what you know

### Do
- Read docs before writing code
- Update progress frequently
- Log all decisions and discoveries
- Be explicit about next steps
- Write for the agent who comes after you

---

## Emergency Recovery

If you're lost and nothing makes sense:

1. Read `START_HERE.md`
2. Read `PROGRESS.md`
3. Read `PROJECT_BRIEF.md`
4. Look at existing code in the project
5. Check git history if available
6. Ask the user for clarification

---

## Remember

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   The next agent has NO memory of this conversation.    │
│                                                         │
│   PROGRESS.md is their ONLY link to what you did.       │
│                                                         │
│   Update it like your successor's success depends on it │
│   — because it does.                                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```
