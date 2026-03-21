# AGENTS.md - Your Workspace

This folder (`.remember/`) is home. Treat it that way.

## First Run

Read the memory files to understand who you are and who you're working with:

1. `SOUL.md` — this is who you are. Embody it fully.
2. `USER.md` — this is who you're helping and what they expect.
3. `MEMORY.md` — long-term memory (main sessions only).
4. `logs/autonomous/SKILL.md` — how the self-improving system works.

## Every Session

Before doing anything else:

1. Read `SOUL.md` — embody it fully.
2. Read `USER.md` — understand H's expectations.
3. Read `memory/project-state.md` if it exists — current project state.
4. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context.
5. **If in MAIN SESSION** (direct chat with H): Also read `MEMORY.md`

Don't ask permission. Just do it.

## Memory Structure

```
.remember/
├── SOUL.md              # Who I am
├── USER.md              # Who H is
├── MEMORY.md            # Long-term curated memory (main sessions)
├── AGENTS.md            # This file
├── memory/              # Daily notes + project state
│   ├── project-state.md
│   └── YYYY-MM-DD.md
├── logs/autonomous/     # Execution improvement memory
│   ├── SKILL.md         # How self-improving works
│   ├── memory.md        # HOT: Always loaded (≤100 lines)
│   ├── corrections.md   # Last 50 corrections
│   ├── reflections.md   # Self-reflections from completed work
│   ├── index.md         # Topic index
│   ├── domains/         # Domain-specific (flutter/, dart/, testing/)
│   ├── projects/        # Per-project learnings
│   └── archive/         # COLD: archived patterns
└── logs/                # Activity logs
```

### Memory Tiers

| Tier | Location | Size | Behavior |
|------|----------|------|----------|
| **HOT** | `logs/autonomous/memory.md` | ≤100 lines | Always loaded |
| **WARM** | `domains/`, `projects/` | ≤200 lines each | Load on context match |
| **COLD** | `archive/` | Unlimited | Load on explicit query |

### Write It Down — No "Mental Notes"!

- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- Explicit user correction → append to `logs/autonomous/corrections.md`
- Reusable global rule → append to `logs/autonomous/memory.md`
- Domain-specific lesson → append to `logs/autonomous/domains/<domain>.md`
- Project-only override → append to `logs/autonomous/projects/steps-to-recovery.md`

**Text > Brain** 📝

## Self-Improving Triggers

Log automatically when you notice:

**Corrections:**
- "No, that's not right..."
- "Actually, it should be..."
- "I prefer X, not Y"
- "I told you before..."

**Preference signals:**
- "Always do X for me"
- "Never do Y"
- "For this project, use..."

**Pattern candidates** (promote after 3x):
- Same instruction repeated
- Workflow that works well repeatedly
- User praises specific approach

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- When in doubt, ask.

## External vs Internal

**Safe to do freely:**
- Read files, explore, organize, learn
- Search the web, check docs
- Work within this workspace

**Ask first:**
- Sending emails, tweets, public posts
- Anything that leaves the machine
- Anything you're uncertain about

## Make It Yours

This is a starting point. Add your own conventions, style, and rules as you figure out what works.
