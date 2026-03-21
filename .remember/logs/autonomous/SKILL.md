---
name: Self-Improving Agent (Proactive + Self-Reflection)
slug: self-improving
version: 1.0.0
description: "Self-reflection + Self-criticism + Self-learning + Self-organizing memory. Agent evaluates its own work, catches mistakes, and improves permanently. Use when (1) a command, tool, API, or operation fails; (2) the user corrects you or rejects your work; (3) you realize your knowledge is outdated or incorrect; (4) you discover a better approach; (5) the user explicitly references self-improving for the current task."
---

## When to Use

User corrects you or points out mistakes. You complete significant work and want to evaluate the outcome. You notice something in your own output that could be better. Knowledge should compound over time without manual maintenance.

## Architecture

Memory lives in `.remember/logs/autonomous/` with tiered structure.

```
.remember/logs/autonomous/
├── SKILL.md           # This file
├── memory.md          # HOT: ≤100 lines, always loaded
├── index.md           # Topic index
├── projects/          # Per-project learnings
├── domains/           # Domain-specific (flutter, dart, testing, etc.)
├── archive/           # COLD: decayed patterns
└── corrections.md     # Last 50 corrections log
```

## Quick Reference

| Topic | File |
|-------|------|
| Learning mechanics | See "Learning Mechanics" section below |
| Memory template | `memory.md` |
| Corrections log | `corrections.md` |
| Reflections log | `reflections.md` |
| Scaling rules | See "Scaling Patterns" section below |

## Detection Triggers

Log automatically when you notice these patterns:

**Corrections** → add to `corrections.md`, evaluate for `memory.md`:
- "No, that's not right..."
- "Actually, it should be..."
- "You're wrong about..."
- "I prefer X, not Y"
- "Remember that I always..."
- "I told you before..."
- "Stop doing X"
- "Why do you keep..."

**Preference signals** → add to `memory.md` if explicit:
- "I like when you..."
- "Always do X for me"
- "Never do Y"
- "My style is..."
- "For [project], use..."

**Pattern candidates** → track, promote after 3x:
- Same instruction repeated 3+ times
- Workflow that works well repeatedly
- User praises specific approach

**Ignore** (don't log):
- One-time instructions ("do X now")
- Context-specific ("in this file...")
- Hypotheticals ("what if...")

## Learning Mechanics

### What Triggers Learning

| Trigger | Confidence | Action |
|---------|------------|--------|
| "No, do X instead" | High | Log correction immediately |
| "I told you before..." | High | Flag as repeated, bump priority |
| "Always/Never do X" | Confirmed | Promote to preference |
| User edits your output | Medium | Log as tentative pattern |
| Same correction 3x | Confirmed | Ask to make permanent |
| "For this project..." | Scoped | Write to project namespace |

### What Does NOT Trigger Learning

- Silence (not confirmation)
- Single instance of anything
- Hypothetical discussions
- Third-party preferences ("John likes...")
- Group chat patterns (unless user confirms)
- Implied preferences (never infer)

### Correction Classification

**By Type:**
| Type | Example | Namespace |
|------|---------|-----------|
| Format | "Use bullets not prose" | global |
| Technical | "SQLite not Postgres" | domain/code |
| Communication | "Shorter messages" | global |
| Project-specific | "This repo uses flutter_lints" | projects/{name} |
| Person-specific | "H wants direct answers" | domains/comms |

**By Scope:**
```
Global: applies everywhere
  └── Domain: applies to category (code, writing, comms)
       └── Project: applies to specific context
            └── Temporary: applies to this session only
```

### Confirmation Flow

After 3 similar corrections:
```
Agent: "I've noticed you prefer X over Y (corrected 3 times).
        Should I always do this?
        - Yes, always
        - Only in [context]
        - No, case by case"

User: "Yes, always"

Agent: → Moves to Confirmed Preferences
       → Removes from correction counter
       → Cites source on future use
```

### Pattern Evolution

**Stages:**
1. **Tentative** — Single correction, watch for repetition
2. **Emerging** — 2 corrections, likely pattern
3. **Pending** — 3 corrections, ask for confirmation
4. **Confirmed** — User approved, permanent unless reversed
5. **Archived** — Unused 90+ days, preserved but inactive

**Reversal:**
User can always reverse:
```
User: "Actually, I changed my mind about X"

Agent: 
1. Archive old pattern (keep history)
2. Log reversal with timestamp
3. Add new preference as tentative
4. "Got it. I'll do Y now. (Previous: X, archived)"
```

## Self-Reflection

After completing significant work, pause and evaluate:

1. **Did it meet expectations?** — Compare outcome vs intent
2. **What could be better?** — Identify improvements for next time
3. **Is this a pattern?** — If yes, log to `corrections.md`

**When to self-reflect:**
- After completing a multi-step task
- After receiving feedback (positive or negative)
- After fixing a bug or mistake
- When you notice your output could be better

**Log format:**
```
CONTEXT: [type of task]
REFLECTION: [what I noticed]
LESSON: [what to do differently]
```

**Example:**
```
CONTEXT: Building Flutter UI
REFLECTION: Spacing looked off, had to redo
LESSON: Check visual spacing before showing user
```

Self-reflection entries follow the same promotion rules: 3x applied successfully → promote to HOT.

## Quick Queries

| User says | Action |
|-----------|--------|
| "What do you know about X?" | Search all tiers for X |
| "What have you learned?" | Show last 10 from `corrections.md` |
| "Show my patterns" | List `memory.md` (HOT) |
| "Show [project] patterns" | Load `projects/{name}.md` |
| "What's in warm storage?" | List files in `projects/` + `domains/` |
| "Memory stats" | Show counts per tier |
| "Forget X" | Remove from all tiers (confirm first) |

## Memory Stats

On "memory stats" request, report:

```
📊 Self-Improving Memory

HOT (always loaded):
  memory.md: X entries

WARM (load on demand):
  projects/: X files
  domains/: X files

COLD (archived):
  archive/: X files

Recent activity (7 days):
  Corrections logged: X
  Promotions to HOT: X
  Demotions to WARM: X
```

## Scaling Patterns

### Volume Thresholds

| Scale | Entries | Strategy |
|-------|---------|----------|
| Small | <100 | Single memory.md, no namespacing |
| Medium | 100-500 | Split into domains/, basic indexing |
| Large | 500-2000 | Full namespace hierarchy, aggressive compaction |
| Massive | >2000 | Archive yearly, summary-only HOT tier |

### When to Split

Create new namespace file when:
- Single file exceeds 200 lines
- Topic has 10+ distinct corrections
- User explicitly separates contexts ("for work...", "in this project...")

### Compaction Rules

**Merge Similar Corrections:**
```
BEFORE (3 entries):
- [02-01] Use tabs not spaces
- [02-03] Indent with tabs
- [02-05] Tab indentation please

AFTER (1 entry):
- Indentation: tabs (confirmed 3x, 02-01 to 02-05)
```

**Summarize Verbose Patterns:**
```
BEFORE:
- When writing code for Flutter, use Material 3, test on device,
  check for offline flows, prefer stateless widgets

AFTER:
- Flutter code: Material 3, device-tested, offline-aware, prefer stateless
```

**Archive with Context:**
When moving to COLD:
```
## Archived 2026-02

### Project: old-feature (inactive since 2025-08)
- Used old animation patterns
- Preferred setState over Riverpod

Reason: Feature completed, patterns unlikely to apply
```

### Index Maintenance

`index.md` tracks all namespaces. See the actual `index.md` file for current state.

### Multi-Project Patterns

**Inheritance Chain:**
```
global (memory.md)
  └── domain (domains/code.md)
       └── project (projects/app.md)
```

**Override Syntax:**
In project file:
```markdown
## Overrides
- indentation: spaces (overrides global tabs)
- Reason: Project uses flutter_lints which requires spaces
```

**Conflict Detection:**
When loading, check for conflicts:
1. Build inheritance chain
2. Detect contradictions
3. Most specific wins
4. Log conflict for later review

## Core Rules

### 1. Learn from Corrections and Self-Reflection
- Log when user explicitly corrects you
- Log when you identify improvements in your own work
- Never infer from silence alone
- After 3 identical lessons → ask to confirm as rule

### 2. Tiered Storage
| Tier | Location | Size Limit | Behavior |
|------|----------|------------|----------|
| HOT | memory.md | ≤100 lines | Always loaded |
| WARM | projects/, domains/ | ≤200 lines each | Load on context match |
| COLD | archive/ | Unlimited | Load on explicit query |

### 3. Automatic Promotion/Demotion
- Pattern used 3x in 7 days → promote to HOT
- Pattern unused 30 days → demote to WARM
- Pattern unused 90 days → archive to COLD
- Never delete without asking

### 4. Namespace Isolation
- Project patterns stay in `projects/{name}.md`
- Global preferences in HOT tier (memory.md)
- Domain patterns (code, writing) in `domains/`
- Cross-namespace inheritance: global → domain → project

### 5. Conflict Resolution
When patterns contradict:
1. Most specific wins (project > domain > global)
2. Most recent wins (same level)
3. If ambiguous → ask user

### 6. Compaction
When file exceeds limit:
1. Merge similar corrections into single rule
2. Archive unused patterns
3. Summarize verbose entries
4. Never lose confirmed preferences

### 7. Transparency
- Every action from memory → cite source: "Using X (from projects/foo.md:12)"
- Full export on demand: all files

### 8. Graceful Degradation
If context limit hit:
1. Load only memory.md (HOT)
2. Load relevant namespace on demand
3. Never fail silently — tell user what's not loaded

## Scope

This system ONLY:
- Learns from user corrections and self-reflection
- Stores preferences in local files (`.remember/logs/autonomous/`)
- Reads its own memory files on activation

This system NEVER:
- Accesses calendar, email, or contacts
- Makes network requests
- Reads files outside `.remember/`
- Infers preferences from silence or observation
- Modifies its own SKILL.md
