# Self-Improving Skill

## Purpose
Enable continuous learning through self-reflection, self-criticism, and compounding memory. This skill captures lessons learned, user corrections, and discovered patterns to improve future performance.

## When to Trigger

Use this skill when ANY of these conditions occur:

| Trigger | Example |
|---------|---------|
| **Command fails** | Build error, test failure, API error |
| **User corrects you** | "That's not how I do it", "Use batch files instead" |
| **Knowledge is outdated** | API changed, deprecated method used |
| **Better approach discovered** | Found simpler pattern, optimization |
| **Significant work completed** | Feature done, migration complete |
| **Context getting long** | Proactively compact learnings |

## Memory Structure

Write to `.remember/logs/autonomous/` with tiered organization:

```
.remember/logs/autonomous/
├── SKILL.md           # This file
├── memory.md          # HOT: ≤100 lines, always loaded
├── index.md           # Topic index
├── corrections.md     # Last 50 corrections log
├── reflections.md     # Self-reflections from completed work
├── projects/          # Per-project learnings
│   └── steps-to-recovery.md
├── domains/           # Domain-specific (flutter, dart, testing, etc.)
│   ├── flutter.md
│   ├── dart.md
│   └── testing.md
└── archive/           # COLD: decayed patterns
```

**Note:** This skill is integrated with the `.remember/` memory system. All learnings are stored in `.remember/logs/autonomous/` and loaded automatically at the start of each session via the memory-loader agent.

## Commands

Users can query learned knowledge:

| Command | Action |
|---------|--------|
| `what have you learned?` | Show recent learnings from `corrections.md` |
| `show my patterns` | List HOT memory (`memory.md`) |
| `memory stats` | Show counts per tier |
| `remember that I always...` | Add new pattern to `memory.md` |
| `show [project] patterns` | Load `projects/[name].md` |
| `forget X` | Remove pattern (confirms first) |

## Writing Patterns

### 1. Session Log Format (Daily Notes)

Write to `.remember/memory/YYYY-MM-DD.md`:

```markdown
# YYYY-MM-DD — Session Notes

## Session Start
- **Date:** [Date]
- **Timezone:** Australia/Sydney (GMT+11)
- **Context:** [What we're working on]

## Key Actions
- [Action 1]
- [Action 2]

## Project Context
[Brief status update]

## Recent Changes
[What changed today]

## Next Steps
[Awaiting user direction]
```

### 2. Pattern Format (HOT Memory)

Write to `.remember/logs/autonomous/memory.md`:

```markdown
## [Category]

- **[Pattern name]** — [Brief description]
  - Example: `- **Card styling** — gray default, amber for primary only`
```

### 3. Correction Format

Write to `.remember/logs/autonomous/corrections.md`:

```markdown
## [Date] — [Topic]

**Correction:** [What user said]
**Context:** [What triggered it]
**Count:** [How many times]
**Action:** [Where stored if promoted]
```

### 4. Domain-Specific Patterns

Write to `.remember/logs/autonomous/domains/<domain>.md`:

```markdown
# <Domain> Patterns

## Conventions
- [Convention 1]
- [Convention 2]

## Common Pitfalls
- [Pitfall 1 with solution]
```

### 5. Project-Specific Overrides

Write to `.remember/logs/autonomous/projects/<project>.md`:

```markdown
# <Project> Patterns

## Overrides
- [Override 1] (overrides global pattern X)
- Reason: [Why]
```

## Integration with Other Skills

### After `flutter-fix` Completes
```
1. Run flutter-fix skill
2. If success: Log what fixed it to `.remember/logs/autonomous/domains/flutter.md`
3. If failure: Log error pattern and workaround
4. Extract reusable pattern if discovered
```

### After User Correction
```
1. Acknowledge correction
2. Write to `.remember/logs/autonomous/corrections.md` immediately
3. Evaluate for promotion to `memory.md`
4. Confirm learning is stored
```

### Before Context Compaction
```
1. Review conversation for key learnings
2. Write session summary to `.remember/memory/YYYY-MM-DD.md`
3. Extract any new patterns to appropriate domain/project files
4. Update `index.md` with new file counts
```

## Examples

### Example 1: After Build Fix

**Trigger:** Successfully fixed Gradle build errors

**Action:**
```markdown
# 2026-03-27 — Gradle Build Fixes

## Session Start
- **Date:** 2026-03-27
- **Context:** Fixed Gradle deprecations

## Key Actions
- Migrated `kotlinOptions.jvmTarget` to new DSL
- Fixed `project.buildDir` deprecation

## What I Learned
- Kotlin DSL changed in Gradle 8.x
- Use `layout.buildDirectory.get()` for build dir
```

### Example 2: After User Preference

**Trigger:** User says "prefer batch files over PowerShell for PATH"

**Action:**
```markdown
## Corrections

## 2026-03-27 — Windows PATH Modifications

**Correction:** "Use batch files not PowerShell"
**Context:** PATH modification script
**Count:** 1
**Action:** Logged to memory.md
```

## Best Practices

1. **Write Immediately** - Don't batch learnings; write as soon as triggered
2. **Be Specific** - Include exact commands, file paths, error messages
3. **Extract Patterns** - Convert specific fixes into reusable patterns
4. **Link Related** - Cross-reference related patterns and sessions
5. **Keep Concise** - Future readers need signal, not noise
6. **Cite Sources** - When using memory, cite file:line (e.g., "from memory.md:12")

## Completion Criteria

After using this skill:
- ✓ Learning is written to `.remember/logs/autonomous/` or `.remember/memory/`
- ✓ Pattern extracted if reusable
- ✓ User can query with "what have you learned?"
- ✓ Future sessions benefit from stored knowledge
- ✓ Index updated if new files created
