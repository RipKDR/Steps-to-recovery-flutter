# Versioning Strategy

This document defines the versioning and rollback strategy for the self-evolving agent system.

## Version Numbering

### Semantic Versioning

Use semantic versioning for all components:

```
MAJOR.MINOR.PATCH
```

- **MAJOR**: Breaking changes to schema or behavior
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Version Tags

Git tags for releases:

```
v1.0.0          # Initial release
v1.1.0          # New features
v1.1.1          # Bug fix
v2.0.0          # Breaking changes
```

## File Versioning

### Skill Files

Each SKILL.md includes version metadata:

```markdown
# Skill Name

**Version:** 1.0.0
**Last Updated:** 2026-04-02
**Status:** Production-Ready
```

### Agent Files

Each agent file includes version metadata:

```markdown
# Agent Name

**Version:** 1.0.0
**Last Updated:** 2026-04-02
**Capabilities:** List of capabilities
```

### Knowledge Entries

Each learning entry includes timestamp:

```json
{
  "Timestamp": "2026-04-02T14:30:00",
  "Status": "Integrated",
  "IntegratedAt": "2026-04-02T14:35:00"
}
```

## Backup Strategy

### Backup Types

#### Full Backup

Complete copy of all knowledge files.

**When:**
- Weekly (Sunday 2:00 AM)
- Before major updates
- Before rollback

**Retention:** 10 most recent

#### Incremental Backup

Only changed files.

**When:**
- Before each update
- After integration

**Retention:** 5 most recent

### Backup Naming

```
YYYYMMDD-HHMMSS-[Type]

Examples:
20260402-143000-Full
20260402-150000-Incremental
```

### Backup Contents

```
backups/
└── 20260402-143000/
    ├── manifest.json
    ├── skills/
    │   └── {skill-name}/
    │       └── SKILL.md
    ├── agents/
    │   └── {agent-name}.md
    ├── memory/
    │   └── .remember/
    └── config/
        ├── AGENTS.md
        ├── QWEN.md
        └── CLAUDE.md
```

### Backup Manifest

```json
{
  "Timestamp": "20260402-143000",
  "Created": "2026-04-02 14:30:00",
  "Type": "Full",
  "Stats": {
    "Skills": 10,
    "Agents": 5,
    "Memory": 25,
    "Config": 3,
    "TotalSize": 125.5
  },
  "Files": [...]
}
```

## Rollback Procedures

### Rollback Triggers

Rollback may be triggered by:

1. **User Request**: User explicitly requests rollback
2. **Error Detection**: System detects errors after update
3. **Validation Failure**: Post-update validation fails
4. **Conflict**: Unresolvable knowledge conflict
5. **Corruption**: File corruption detected

### Rollback Levels

#### Level 1: Single File Rollback

Restore a single file from backup.

```powershell
.\rollback.ps1 -File "skills/flutter/SKILL.md" -Version "20260401-120000"
```

#### Level 2: Component Rollback

Restore a component (all skills or all agents).

```powershell
.\rollback.ps1 -Component skills -Version "20260401-120000"
```

#### Level 3: Full Rollback

Restore entire knowledge base.

```powershell
.\rollback.ps1 -Version "20260401-120000"
```

#### Level 4: Git Rollback

Restore from git history.

```powershell
.\rollback.ps1 -Version "HEAD~1"
.\rollback.ps1 -Version "v1.0.0"
```

### Rollback Algorithm

```
1. Validate rollback target exists
2. Create pre-rollback backup
3. Stop auto-learning
4. Restore files from backup
5. Validate restored files
6. Re-apply valid learnings after backup date
7. Resume auto-learning
8. Log rollback with reason
```

### Rollback Validation

After rollback:

```powershell
function Test-RollbackSuccess {
    $checks = @(
        @{ Name = "Files Restored"; Test = { Test-FilesExist } }
        @{ Name = "Valid Syntax"; Test = { Test-MarkdownSyntax } }
        @{ Name = "No Corruption"; Test = { Test-FileIntegrity } }
        @{ Name = "Memory Consistent"; Test = { Test-MemoryConsistency } }
    )
    
    $failed = @()
    foreach ($check in $checks) {
        if (-not (& $check.Test)) {
            $failed += $check.Name
        }
    }
    
    if ($failed.Count -gt 0) {
        throw "Rollback validation failed: $($failed -join ', ')"
    }
}
```

## Change Tracking

### Git Commits

All changes are committed to git:

```
chore(skills): auto-update 3 skills with new learnings
chore(agents): auto-update 2 agents with corrections
chore(knowledge): integrated 15 learnings
chore(config): promote 5 learnings to config files
fix: rollback to v1.0.0 due to integration error
```

### Commit Message Format

```
<type>(<scope>): <description>

Types:
- chore: Maintenance tasks
- feat: New features
- fix: Bug fixes
- docs: Documentation changes
- refactor: Code refactoring
- test: Test additions/changes
- revert: Revert previous commit
```

### Change Log

Maintain CHANGELOG.md:

```markdown
# Changelog

## [1.1.0] - 2026-04-02

### Added
- Auto-learning after every response
- Documentation fetching for Flutter/Dart

### Changed
- Improved knowledge integration algorithm

### Fixed
- Fixed duplicate detection in learnings
```

## Recovery Procedures

### Disaster Recovery

If entire knowledge base is lost:

1. **Check Git**: Restore from git history
2. **Check Backups**: Restore from latest backup
3. **Check Remote**: If synced remotely, restore from remote
4. **Rebuild**: If all else fails, rebuild from scratch

### Recovery Script

```powershell
.\recover-knowledge.ps1 -Source git -Target v1.0.0
.\recover-knowledge.ps1 -Source backup -Target 20260402-143000
```

### Recovery Validation

After recovery:

```powershell
.\validate-knowledge.ps1 -Full
```

## Migration Procedures

### Schema Migration

When schema changes:

1. **Backup**: Create full backup
2. **Migrate**: Run migration script
3. **Validate**: Validate migrated data
4. **Test**: Run integration tests
5. **Deploy**: Deploy migration

### Migration Script Template

```powershell
param(
    [string]$FromVersion,
    [string]$ToVersion
)

# Backup
.\backup-knowledge.ps1 -Full

# Migrate
$learnings = Get-Content "general-learnings.json" | ConvertFrom-Json

foreach ($learning in $learnings) {
    # Apply migration logic
    $learning.newField = "defaultValue"
}

# Save
$learnings | ConvertTo-Json | Set-Content "general-learnings.json"

# Validate
.\validate-knowledge.ps1

Write-Host "Migration complete: $FromVersion -> $ToVersion"
```

## Monitoring

### Version Metrics

Track:

| Metric | Target | Alert |
|--------|--------|-------|
| Backup Success Rate | >99% | <95% |
| Rollback Success Rate | >95% | <90% |
| Recovery Time | <5 min | >10 min |
| Data Loss | 0% | >0% |

### Health Checks

Daily health check:

```powershell
function Invoke-DailyHealthCheck {
    $checks = @(
        @{ Name = "Backups Exist"; Test = { Test-BackupsPresent } }
        @{ Name = "Git Synced"; Test = { Test-GitSynced } }
        @{ Name = "No Corruption"; Test = { Test-FileIntegrity } }
        @{ Name = "Disk Space"; Test = { Test-DiskSpace } }
    )
    
    $results = @{}
    foreach ($check in $checks) {
        $results[$check.Name] = & $check.Test
    }
    
    return $results
}
```

---

**Version:** 1.0.0  
**Last Updated:** 2026-04-02  
**Maintained By:** Self-Evolving Agent
