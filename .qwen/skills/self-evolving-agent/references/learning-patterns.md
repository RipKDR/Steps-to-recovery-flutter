# Learning Patterns Reference

This document defines patterns for extracting learnings from various situations.

## Pattern Categories

### 1. Correction Patterns

Detected when user explicitly corrects the agent.

**Triggers:**
- "No, that's wrong"
- "Actually, ..."
- "Not quite"
- "I said ..."
- "Remember that ..."

**Learning Format:**
```json
{
  "Category": "Correction",
  "Topic": "Specific topic corrected",
  "Context": "What was the original mistake",
  "Observation": "What the user corrected",
  "Insight": "What should have been done",
  "Action": "How to prevent this in future",
  "Priority": "High"
}
```

### 2. Success Patterns

Detected when something works well.

**Triggers:**
- "That worked"
- "Perfect"
- "Thanks"
- "Great"
- User continues with next task (implicit success)

**Learning Format:**
```json
{
  "Category": "Success",
  "Topic": "What worked well",
  "Context": "Situation where it worked",
  "Observation": "What was done",
  "Insight": "Why it worked",
  "Action": "Continue doing this",
  "Priority": "Low"
}
```

### 3. Error Patterns

Detected when agent encounters errors.

**Triggers:**
- Error messages in output
- "Failed to..."
- "Couldn't..."
- "Unable to..."
- Exception stack traces

**Learning Format:**
```json
{
  "Category": "Error",
  "Topic": "Error type",
  "Context": "What caused the error",
  "Observation": "Error message",
  "Insight": "Root cause analysis",
  "Action": "Prevention strategy",
  "Priority": "High"
}
```

### 4. Preference Patterns

Detected when user states preferences.

**Triggers:**
- "Always ..."
- "Never ..."
- "I prefer ..."
- "Don't ..."
- "Please ..."

**Learning Format:**
```json
{
  "Category": "Preference",
  "Topic": "Preference area",
  "Context": "When this applies",
  "Observation": "What user prefers",
  "Insight": "Why this matters",
  "Action": "Apply this preference",
  "Priority": "Medium"
}
```

### 5. Knowledge Gap Patterns

Detected when agent lacks information.

**Triggers:**
- "I don't know..."
- "I'm not sure..."
- Agent asks for clarification
- Agent provides incomplete answer

**Learning Format:**
```json
{
  "Category": "KnowledgeGap",
  "Topic": "Missing knowledge area",
  "Context": "When the gap was discovered",
  "Observation": "What information was missing",
  "Insight": "Why this knowledge is needed",
  "Action": "Fetch documentation or learn",
  "Priority": "Medium"
}
```

## Extraction Rules

### Rule 1: Context Preservation
Always capture enough context to understand the situation later.

**Good:**
```
Context: User was implementing ChangeNotifier for counter feature
```

**Bad:**
```
Context: Counter
```

### Rule 2: Actionable Insights
Insights must be specific enough to drive action.

**Good:**
```
Insight: Always check `if (!mounted) return;` after async operations
```

**Bad:**
```
Insight: Be careful with async
```

### Rule 3: Clear Actions
Actions must be implementable.

**Good:**
```
Action: Update flutter-state skill with mounted check pattern
```

**Bad:**
```
Action: Fix this
```

### Rule 4: Priority Assignment
Assign priority based on impact:

- **Critical**: Security issues, data loss, blocking errors
- **High**: Frequent errors, user corrections, core functionality
- **Medium**: Preferences, optimizations, nice-to-haves
- **Low**: Success patterns, minor improvements

## Pattern Matching Examples

### Example 1: User Correction

**User Message:**
```
No, that's wrong. I said to use tabs not spaces.
```

**Extracted Learning:**
```json
{
  "Category": "Correction",
  "Topic": "Code Formatting - Tabs vs Spaces",
  "Context": "Agent used spaces in generated code",
  "Observation": "User prefers tabs over spaces",
  "Insight": "Project uses tabs for indentation",
  "Action": "Update all code generation to use tabs",
  "Priority": "High"
}
```

### Example 2: Error Detection

**Agent Response:**
```
Error: Failed to connect to database. Timeout after 30s.
```

**Extracted Learning:**
```json
{
  "Category": "Error",
  "Topic": "Database Connection Timeout",
  "Context": "Attempting to connect to Supabase",
  "Observation": "Connection timeout after 30 seconds",
  "Insight": "Network connectivity or credentials issue",
  "Action": "Add retry logic and better error messages",
  "Priority": "High"
}
```

### Example 3: Preference Statement

**User Message:**
```
Always run tests before committing changes.
```

**Extracted Learning:**
```json
{
  "Category": "Preference",
  "Topic": "Pre-commit Testing",
  "Context": "Code commit workflow",
  "Observation": "User wants tests run before every commit",
  "Insight": "Ensures code quality and prevents regressions",
  "Action": "Add pre-commit hook to run tests",
  "Priority": "Medium"
}
```

## Integration Guidelines

### When to Integrate

1. **Immediate**: High/Critical priority learnings
2. **Batch**: Medium/Low priority (after 10+ learnings)
3. **Scheduled**: Daily review of all pending learnings

### Where to Integrate

Based on topic:
- **Flutter**: `.remember/logs/autonomous/domains/flutter.md`
- **Dart**: `.remember/logs/autonomous/domains/dart.md`
- **Testing**: `.remember/logs/autonomous/domains/testing.md`
- **Project**: `.remember/logs/autonomous/projects/steps-to-recovery.md`
- **General**: `.remember/logs/autonomous/memory.md`
- **Corrections**: `.remember/logs/autonomous/corrections.md`

### How to Integrate

1. Read existing knowledge file
2. Check for duplicates (same topic within 24h)
3. Append new learning with timestamp
4. Update any related skills/agents
5. Mark learning as integrated

## Quality Checks

Before accepting a learning:

- [ ] Is the context clear?
- [ ] Is the insight actionable?
- [ ] Is the action implementable?
- [ ] Is the priority appropriate?
- [ ] Is this a duplicate?
- [ ] Does this conflict with existing knowledge?

## Deprecation

Mark learnings as obsolete when:
- Superseded by newer learning
- No longer applicable (project changed)
- Found to be incorrect

Add deprecation note:
```
[DEPRECATED 2026-04-02] Superseded by: [new learning reference]
Reason: Project migrated to new architecture
```

---

**Version:** 1.0.0  
**Last Updated:** 2026-04-02  
**Maintained By:** Self-Evolving Agent
