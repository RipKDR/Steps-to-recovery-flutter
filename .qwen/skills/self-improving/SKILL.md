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

Write to `~/self-improving/` with tiered organization:

```
~/self-improving/
├── patterns/        # Recurring patterns (always-persisted)
│   ├── windows-flutter.md
│   └── gradle-fixes.md
├── corrections/     # User-specific corrections
│   └── user-H-corrections.md
├── discoveries/     # Better approaches discovered
│   └── build-optimizations.md
└── sessions/        # Session-specific learnings (rotated)
    └── 2026-03-26-gradle-build-fix.md
```

## Commands

Users can query learned knowledge:

| Command | Action |
|---------|--------|
| `what have you learned?` | Show recent learnings |
| `show my patterns` | List all stored patterns |
| `memory stats` | Show memory usage, file count |
| `remember that I always...` | Add new pattern |

## Writing Patterns

### 1. Session Log Format

```markdown
# Session: [Date] - [Topic]

## What Happened
[Brief description of the task]

## What Went Wrong
[Errors encountered, failures]

## What I Learned
[Key takeaways, patterns discovered]

## Commands That Worked
```bash
[Exact commands that succeeded]
```

## Files Modified
- `path/to/file.dart` - [change summary]

## Future Reference
[How to apply this learning next time]
```

### 2. Pattern Format

```markdown
# Pattern: [Pattern Name]

## When to Apply
[Trigger conditions]

## What to Do
[Step-by-step approach]

## Example
[Concrete example from this project]

## Related
[Links to other patterns, skills]
```

### 3. Correction Format

```markdown
# Correction: [Topic]

## What I Did Wrong
[Incorrect approach I used]

## What User Taught Me
[Correct approach]

## Rule Going Forward
[Specific rule to follow]
```

## Integration with Other Skills

### After `flutter-fix` Completes
```
1. Run flutter-fix skill
2. If success: Log what fixed it to self-improving
3. If failure: Log error pattern and workaround
4. Extract reusable pattern if discovered
```

### After User Correction
```
1. Acknowledge correction
2. Write to corrections/ immediately
3. Update relevant pattern file
4. Confirm learning is stored
```

### Before Context Compaction
```
1. Review conversation for key learnings
2. Write session summary to sessions/
3. Extract any new patterns to patterns/
4. Report what was saved
```

## Examples

### Example 1: After Build Fix

**Trigger:** Successfully fixed Gradle build errors

**Action:**
```markdown
# Session: 2026-03-26 - Gradle Build Fixes

## What Happened
Fixed Gradle compilation errors in android/app/build.gradle.kts

## What Went Wrong
- `kotlinOptions.jvmTarget` deprecated in Gradle 8.14+
- `project.buildDir` deprecated
- Missing `java.util.Properties` import

## What I Learned
- Kotlin DSL changed in Gradle 8.x: use `kotlin { compilerOptions { } }`
- Use `layout.buildDirectory.get()` instead of `project.buildDir`
- Always import `java.util.Properties` explicitly

## Commands That Worked
```bash
C:\src\flutter\bin\flutter.bat build apk --debug
```

## Files Modified
- `android/app/build.gradle.kts` - Fixed deprecations

## Future Reference
When Gradle fails with "Unresolved reference" errors:
1. Check Gradle version in use
2. Look for deprecated API usage
3. Migrate to new DSL syntax
```

### Example 2: After User Preference

**Trigger:** User says "prefer batch files over PowerShell for PATH"

**Action:**
```markdown
# Correction: Windows PATH Modifications

## What I Did Wrong
Used inline PowerShell commands for PATH changes

## What User Taught Me
Use batch files (.bat) for PATH modifications on Windows

## Rule Going Forward
- Windows + PATH changes = create .bat file
- Avoid inline PowerShell for environment modifications
- Batch files are more reliable across Windows versions
```

## Best Practices

1. **Write Immediately** - Don't batch learnings; write as soon as triggered
2. **Be Specific** - Include exact commands, file paths, error messages
3. **Extract Patterns** - Convert specific fixes into reusable patterns
4. **Link Related** - Cross-reference related patterns and sessions
5. **Keep Concise** - Future readers need signal, not noise

## Completion Criteria

After using this skill:
- ✓ Learning is written to appropriate file(s)
- ✓ Pattern extracted if reusable
- ✓ User can query with "what have you learned?"
- ✓ Future sessions benefit from stored knowledge
