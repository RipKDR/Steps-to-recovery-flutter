# Knowledge Schema

This document defines the schema for knowledge entries in the self-evolving agent system.

## Learning Entry Schema

### Core Fields

```typescript
interface LearningEntry {
  // Unique identifier (auto-generated)
  id: string;
  
  // When the learning was captured
  Timestamp: string;  // ISO 8601 format: yyyy-MM-ddTHH:mm:ss
  
  // Category of learning
  Category: LearningCategory;
  
  // Short topic/title (max 100 chars)
  Topic: string;
  
  // Context/situation (max 500 chars)
  Context: string;
  
  // What was observed
  Observation: string;
  
  // Key insight/learning
  Insight: string;
  
  // Action to take
  Action: string;
  
  // Files/areas this applies to
  AppliesTo: string[];
  
  // Priority level
  Priority: PriorityLevel;
  
  // Source of learning
  Source: LearningSource;
  
  // Current status
  Status: LearningStatus;
  
  // When integrated (if applicable)
  IntegratedAt?: string;
  
  // When promoted (if applicable)
  PromotedAt?: string;
  
  // Related learning IDs
  RelatedTo?: string[];
}
```

### Enumerations

```typescript
type LearningCategory = 
  | 'Correction'      // User corrected the agent
  | 'Success'         // Something worked well
  | 'Error'           // Agent encountered an error
  | 'Preference'      // User preference stated
  | 'KnowledgeGap'    // Missing knowledge identified
  | 'Optimization'    // Performance improvement
  | 'Security'        // Security-related learning
  | 'BestPractice'    // Industry best practice
  | 'Pattern'         // Design pattern discovered
  | 'Architecture'    // Architecture decision
  | 'Bug'             // Bug fix learning
  | 'Feature'         // New feature/capability
  | 'Documentation'   // Documentation improvement
  | 'Testing'         // Testing strategy
  | 'Performance'     // Performance optimization
  | 'UX'              // User experience improvement
  | 'AgentImprovement'; // Agent capability improvement

type PriorityLevel = 
  | 'Critical'  // Must fix immediately
  | 'High'      // Should fix soon
  | 'Medium'    // Normal priority
  | 'Low';      // Nice to have

type LearningSource = 
  | 'ResponseAnalysis'  // Auto-detected from response
  | 'UserFeedback'      // Explicit user feedback
  | 'ErrorDetection'    // Auto-detected error
  | 'SelfReflection'    // Agent self-reflection
  | 'PerformanceReview' // Performance analysis
  | 'CodeReview'        // Code review findings
  | 'Testing'           // Test results
  | 'Documentation'     // Documentation update
  | 'SkillImprovement'  // Skill enhancement
  | 'AgentPerformance'  // Agent performance analysis
  | 'Manual';           // Manually entered

type LearningStatus = 
  | 'New'          // Just captured
  | 'Pending'      // Awaiting review
  | 'Integrated'   // Integrated into knowledge base
  | 'Promoted'     // Promoted to config files
  | 'Synced'       // Synced to memory system
  | 'Deprecated'   // No longer valid
  | 'Rejected';    // Reviewed and rejected
```

## Knowledge Base Schema

### General Learnings Store

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-04-02T14:30:00",
  "learnings": [
    {
      "id": "learn-20260402-001",
      "Timestamp": "2026-04-02T14:30:00",
      "Category": "Correction",
      "Topic": "Flutter State Management",
      "Context": "User was implementing ChangeNotifier for counter feature",
      "Observation": "Used setState inside async callback without mounted check",
      "Insight": "Always check `if (!mounted) return;` after async operations in StatefulWidget",
      "Action": "Update flutter-state skill with this pattern",
      "AppliesTo": [
        ".qwen/skills/flutter-state/SKILL.md",
        ".remember/logs/autonomous/domains/flutter.md"
      ],
      "Priority": "high",
      "Source": "ResponseAnalysis",
      "Status": "New"
    }
  ]
}
```

### Identified Gaps Store

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-04-02T14:30:00",
  "gaps": [
    {
      "Category": "Flutter",
      "Topic": "Widget Lifecycle",
      "Description": "Flutter widget lifecycle knowledge gap detected",
      "RecommendedAction": "Fetch Flutter documentation",
      "Priority": "High",
      "Source": "ResponseAnalysis",
      "IdentifiedAt": "2026-04-02T14:30:00"
    }
  ]
}
```

### Backup Manifest Schema

```json
{
  "Timestamp": "20260402-143000",
  "Created": "2026-04-02 14:30:00",
  "Type": "Incremental",
  "Stats": {
    "Skills": 10,
    "Agents": 5,
    "Memory": 25,
    "Config": 3,
    "TotalSize": 125.5
  },
  "Files": [
    "C:\\...\\backups\\20260402-143000\\skills\\flutter\\SKILL.md",
    "..."
  ]
}
```

## Memory File Schema

### Active Memory (memory.md)

```markdown
# Active Memory (HOT)

This file contains currently active patterns and learnings.

- **[2026-04-02 14:30]** Flutter State Management: Always check `if (!mounted) return;` after async operations
- **[2026-04-02 13:15]** Navigation: Use GoRouter for all navigation, not Navigator.push
```

### Corrections Log (corrections.md)

```markdown
# Corrections Log

This file tracks corrections from user feedback and errors.

## 2026-04-02 14:30 - Flutter State Management

**Context:** User was implementing ChangeNotifier for counter feature
**Correction:** Always check `if (!mounted) return;` after async operations
**Action:** Update flutter-state skill with this pattern
```

### Self-Reflections (reflections.md)

```markdown
# Self-Reflections

Agent self-reflections and meta-learnings.

## Error Learning: Database Connection Timeout - 2026-04-02 14:30

**Error Context:** Attempting to connect to Supabase
**Root Cause:** Network connectivity or credentials issue
**Prevention:** Add retry logic and better error messages
```

### Domain Knowledge Schema

```markdown
# {Domain} Domain Knowledge

## Core Concepts

- Concept 1: Description
- Concept 2: Description

## Best Practices

- **Practice 1**: Description
- **Practice 2**: Description

## Common Pitfalls

- **Pitfall 1**: How to avoid
- **Pitfall 2**: How to avoid

## Recent Learnings

- **[2026-04-02]** Learning description
```

## Validation Rules

### Required Fields

Every learning entry MUST have:
- Timestamp
- Category
- Topic
- Context
- Observation
- Insight
- Action
- Priority

### Field Constraints

| Field | Type | Min Length | Max Length | Format |
|-------|------|------------|------------|--------|
| Topic | string | 3 | 100 | Title Case |
| Context | string | 10 | 500 | Sentence |
| Observation | string | 10 | 500 | Sentence |
| Insight | string | 10 | 500 | Sentence |
| Action | string | 10 | 200 | Imperative |

### Priority Guidelines

| Priority | Response Time | Examples |
|----------|---------------|----------|
| Critical | Immediate | Security breach, data loss |
| High | Within 1 hour | User correction, blocking error |
| Medium | Within 24 hours | Preference, optimization |
| Low | Within 1 week | Success pattern, minor improvement |

## Migration Guide

### Version 1.0.0 → 2.0.0

When upgrading schema version:

1. Add `id` field to all existing entries
2. Convert `Priority` to lowercase
3. Add `Source` field based on category
4. Set `Status` to "Integrated" for old entries

```powershell
# Migration script
$learnings = Get-Content "general-learnings.json" | ConvertFrom-Json

foreach ($learning in $learnings) {
    $learning.id = "learn-$(Get-Date -Format 'yyyyMMdd')-$(Get-Random)"
    $learning.Priority = $learning.Priority.ToLower()
    $learning.Source = "Manual"
    $learning.Status = "Integrated"
}

$learnings | ConvertTo-Json | Set-Content "general-learnings.json"
```

---

**Version:** 1.0.0  
**Last Updated:** 2026-04-02  
**Maintained By:** Self-Evolving Agent
