# Integration Rules

This document defines the rules and procedures for integrating new knowledge into the self-evolving agent system.

## Integration Principles

### 1. Non-Destructive Updates

Never overwrite existing knowledge without:
- Creating a backup first
- Marking old knowledge as deprecated
- Preserving history

### 2. Conflict Resolution

When new knowledge conflicts with existing:

1. **Timestamp Priority**: Newer knowledge wins (unless marked as authoritative)
2. **Priority Override**: Higher priority learning overrides lower
3. **Manual Review**: Flag significant conflicts for human review

### 3. Incremental Integration

Integrate in small batches:
- Max 10 learnings per batch
- Validate after each batch
- Rollback on error

## Integration Workflow

### Phase 1: Validation

```powershell
Validate-Learning {
    1. Check required fields
    2. Validate field formats
    3. Check for duplicates
    4. Verify priority assignment
    5. Confirm action is implementable
}
```

**Validation Checklist:**
- [ ] All required fields present
- [ ] Field lengths within limits
- [ ] No duplicates (same topic within 24h)
- [ ] Priority matches impact
- [ ] Action is specific and implementable

### Phase 2: Categorization

Route learning to appropriate target:

```
IF Topic matches "flutter|widget|state" → flutter.md
ELSE IF Topic matches "dart|async|null" → dart.md
ELSE IF Topic matches "test|mock" → testing.md
ELSE IF Category = "Correction" → corrections.md
ELSE IF Category = "Error" → reflections.md
ELSE → memory.md
```

### Phase 3: Deduplication

Check for existing similar entries:

```powershell
function Test-Duplicate {
    param($learning, $existing)
    
    # Same topic within 24 hours
    if ($learning.Topic -eq $existing.Topic -and
        $learning.Timestamp - $existing.Timestamp -lt [TimeSpan]::FromHours(24)) {
        return $true
    }
    
    # Same insight (fuzzy match)
    if (Test-SimilarInsight $learning.Insight $existing.Insight) {
        return $true
    }
    
    return $false
}
```

### Phase 4: Merge

Append to target file:

```markdown
- **[TIMESTAMP]** TOPIC`: INSIGHT
```

### Phase 5: Update Related

Update any skills/agents that reference this knowledge:

```powershell
# Find related skills
$relatedSkills = Find-SkillsByTopic $learning.Topic

# Update each skill
foreach ($skill in $relatedSkills) {
    Update-SkillWithLearning $skill $learning
}
```

### Phase 6: Mark Integrated

Update learning status:

```json
{
  "Status": "Integrated",
  "IntegratedAt": "2026-04-02T14:30:00"
}
```

## Conflict Detection

### Types of Conflicts

#### Type 1: Direct Contradiction

**Example:**
- Existing: "Always use setState for state updates"
- New: "Never use setState, use ChangeNotifier instead"

**Resolution:**
1. Mark existing as deprecated
2. Add new learning
3. Add migration note

#### Type 2: Partial Overlap

**Example:**
- Existing: "Use tabs for indentation"
- New: "Use 4 spaces for indentation"

**Resolution:**
1. Check project configuration
2. Update with specific context
3. Add exception note

#### Type 3: Outdated Knowledge

**Example:**
- Existing: "Use Flutter 2.x API"
- New: "Use Flutter 3.x API (breaking changes)"

**Resolution:**
1. Mark existing as deprecated
2. Add version note
3. Add migration guide reference

### Conflict Resolution Algorithm

```
1. Detect conflict (fuzzy match on topic + contradictory insight)
2. Compare timestamps
3. Compare priorities
4. If new is newer AND (higher priority OR same priority):
   - Deprecate old
   - Add new with conflict note
5. If old is higher priority:
   - Reject new (or flag for review)
6. If unclear:
   - Flag for manual review
```

## Rollback Procedures

### When to Rollback

- Integration caused errors
- Knowledge found to be incorrect
- User requests rollback
- Conflict not properly resolved

### Rollback Steps

```powershell
1. Identify backup to restore
2. Validate backup integrity
3. Stop auto-learning temporarily
4. Restore from backup
5. Re-apply any valid learnings after backup date
6. Resume auto-learning
7. Log rollback reason
```

### Rollback Command

```powershell
.\rollback.ps1 -Version "20260401-120000"
```

## Quality Assurance

### Pre-Integration Checks

```powershell
function Invoke-PreIntegrationCheck {
    param($learning)
    
    $checks = @(
        @{ Name = "Required Fields"; Test = { Test-RequiredFields $learning } }
        @{ Name = "No Duplicates"; Test = { -not (Test-Duplicate $learning) } }
        @{ Name = "Valid Priority"; Test = { Test-ValidPriority $learning.Priority } }
        @{ Name = "Implementable Action"; Test = { Test-ActionImplementable $learning.Action } }
        @{ Name = "No Conflicts"; Test = { -not (Test-Conflict $learning) } }
    )
    
    $failed = @()
    foreach ($check in $checks) {
        if (-not (& $check.Test)) {
            $failed += $check.Name
        }
    }
    
    if ($failed.Count -gt 0) {
        throw "Pre-integration checks failed: $($failed -join ', ')"
    }
}
```

### Post-Integration Validation

```powershell
function Invoke-PostIntegrationValidation {
    param($targetFile)
    
    $checks = @(
        @{ Name = "File Exists"; Test = { Test-Path $targetFile } }
        @{ Name = "Valid Markdown"; Test = { Test-MarkdownSyntax $targetFile } }
        @{ Name = "Learning Added"; Test = { Test-LearningPresent $targetFile } }
        @{ Name = "No Corruption"; Test = { Test-FileIntegrity $targetFile } }
    )
    
    $failed = @()
    foreach ($check in $checks) {
        if (-not (& $check.Test)) {
            $failed += $check.Name
        }
    }
    
    if ($failed.Count -gt 0) {
        throw "Post-integration validation failed: $($failed -join ', ')"
    }
}
```

## Monitoring

### Metrics to Track

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Integration Success Rate | >95% | <90% |
| Conflict Rate | <5% | >10% |
| Rollback Rate | <2% | >5% |
| Duplicate Rate | <1% | >5% |
| Average Integration Time | <1s | >5s |

### Logging

Every integration must log:

```
[TIMESTAMP] [INFO] Integrating learning: {Topic}
[TIMESTAMP] [INFO] Target: {TargetFile}
[TIMESTAMP] [INFO] Pre-checks: {Passed/Failed}
[TIMESTAMP] [INFO] Integration: {Success/Failed}
[TIMESTAMP] [INFO] Post-validation: {Passed/Failed}
```

## Special Cases

### High-Volume Learning

When receiving >50 learnings/hour:

1. Enable batch mode
2. Increase deduplication strictness
3. Defer non-critical integrations
4. Alert for review

### Critical Learning

For Critical priority learnings:

1. Integrate immediately (skip batching)
2. Update all related skills
3. Promote to config files
4. Notify user

### Ambiguous Learning

When learning is unclear:

1. Flag for manual review
2. Store in pending-ambiguous.json
3. Request clarification from user
4. Do not integrate until clarified

---

**Version:** 1.0.0  
**Last Updated:** 2026-04-02  
**Maintained By:** Self-Evolving Agent
