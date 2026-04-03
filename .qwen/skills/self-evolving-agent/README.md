# Self-Evolving Agent Skill

**Version:** 2.0.0  
**Status:** Production-Ready  
**Platform:** Windows PowerShell 5.1+

## Quick Start

### Validate Installation

```powershell
.\.qwen\skills\self-evolving-agent\scripts\validate-self-skill.ps1
```

### Run First Improvement Cycle

```powershell
.\.qwen\skills\self-evolving-agent\scripts\run-improvement-cycle.ps1
```

## What This Skill Does

The Self-Evolving Agent is a comprehensive, autonomous learning system that:

1. **Auto-Learns** after every response - analyzes what could have been done better
2. **Self-Updates Skills** - automatically improves all installed skills with new knowledge
3. **Self-Updates Agents** - enhances agent definitions based on performance
4. **Fetches Documentation** - automatically gets latest Flutter, Dart, and package docs
5. **Continuous Improvement** - runs improvement cycles after every task
6. **Knowledge Integration** - merges learnings with existing knowledge, resolves conflicts
7. **Version Control** - backs up before changes, supports rollback to any version

## Architecture

```
self-evolving-agent/
├── SKILL.md                    # This skill definition
├── config.json                 # Configuration settings
├── scripts/                    # PowerShell automation
│   ├── analyze-response.ps1   # Analyze response quality
│   ├── update-skills.ps1      # Update skill files
│   ├── update-agents.ps1      # Update agent definitions
│   ├── fetch-docs.ps1         # Fetch documentation
│   ├── integrate-knowledge.ps1 # Integrate new knowledge
│   ├── sync-memory.ps1        # Sync with .remember/
│   ├── run-improvement-cycle.ps1 # Full improvement loop
│   ├── daily-update.ps1       # Daily maintenance
│   ├── weekly-update.ps1      # Weekly maintenance
│   ├── backup-knowledge.ps1   # Create backups
│   ├── rollback.ps1           # Rollback to version
│   └── utils/                 # Utility scripts
├── references/                 # Documentation
│   ├── learning-patterns.md   # How to extract learnings
│   ├── knowledge-schema.md    # Data schema
│   ├── integration-rules.md   # Integration rules
│   ├── doc-sources.md         # Documentation sources
│   └── versioning-strategy.md # Versioning & rollback
├── knowledge/                  # Knowledge base
├── logs/                       # Execution logs
└── doc-cache/                  # Cached documentation
```

## Usage

### Manual Commands

```powershell
# Run full improvement cycle
.\.qwen\skills\self-evolving-agent\scripts\run-improvement-cycle.ps1

# Analyze last response
.\.qwen\skills\self-evolving-agent\scripts\analyze-response.ps1

# Update all skills
.\.qwen\skills\self-evolving-agent\scripts\update-skills.ps1 -All

# Update all agents
.\.qwen\skills\self-evolving-agent\scripts\update-agents.ps1 -All

# Fetch latest docs
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -All

# Integrate knowledge
.\.qwen\skills\self-evolving-agent\scripts\integrate-knowledge.ps1

# Sync memory
.\.qwen\skills\self-evolving-agent\scripts\sync-memory.ps1

# Create backup
.\.qwen\skills\self-evolving-agent\scripts\backup-knowledge.ps1

# Rollback
.\.qwen\skills\self-evolving-agent\scripts\rollback.ps1 -Version "20260401-120000"

# Validate installation
.\.qwen\skills\self-evolving-agent\scripts\validate-self-skill.ps1
```

### Automatic Triggers

The skill automatically runs:

- **After every response**: Analyzes for learnings
- **After errors**: Captures error-based learnings
- **After user feedback**: Processes corrections and preferences
- **Daily at 6 AM**: Fetches docs, integrates knowledge
- **Weekly on Sunday 2 AM**: Full review and optimization

## Configuration

Edit `.qwen/skills/self-evolving-agent/config.json`:

```json
{
  "autoLearn": true,           // Enable auto-learning
  "autoUpdateSkills": true,    // Auto-update skills
  "autoUpdateAgents": true,    // Auto-update agents
  "autoFetchDocs": true,       // Auto-fetch documentation
  "backupBeforeUpdate": true,  // Backup before changes
  "gitCommitChanges": true,    // Commit to git
  "logLevel": "info"           // Debug, info, warning, error
}
```

## Integration with .remember/

The skill integrates with the existing memory system:

| Memory File | Content |
|-------------|---------|
| `memory.md` | Active learnings (HOT memory) |
| `corrections.md` | User corrections |
| `reflections.md` | Self-reflections |
| `domains/flutter.md` | Flutter-specific knowledge |
| `domains/dart.md` | Dart-specific knowledge |
| `domains/testing.md` | Testing knowledge |
| `projects/steps-to-recovery.md` | Project-specific knowledge |

## Learning Format

Learnings are captured in structured format:

```json
{
  "Timestamp": "2026-04-02T14:30:00",
  "Category": "Correction",
  "Topic": "Flutter State Management",
  "Context": "User was implementing ChangeNotifier",
  "Observation": "Used setState without mounted check",
  "Insight": "Always check if (!mounted) after async",
  "Action": "Update flutter-state skill",
  "Priority": "High",
  "Status": "New"
}
```

## Documentation Sources

Automatically fetches from:

- **Flutter**: api.flutter.dev, docs.flutter.dev
- **Dart**: dart.dev
- **Pub.dev**: All packages in pubspec.yaml
- **Qwen**: Local .qwen/ directory

## Rollback

If something goes wrong:

```powershell
# List available backups
Get-ChildItem .qwen\skills\self-evolving-agent\backups\

# Rollback to specific backup
.\.qwen\skills\self-evolving-agent\scripts\rollback.ps1 -Version "20260401-120000"

# Rollback via git
.\.qwen\skills\self-evolving-agent\scripts\rollback.ps1 -Version "HEAD~1"
```

## Troubleshooting

### Scripts won't run

Check PowerShell execution policy:

```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Git not available

Install Git for Windows: https://git-scm.com/download/win

### Validation fails

Run validation with full checks:

```powershell
.\.qwen\skills\self-evolving-agent\scripts\validate-self-skill.ps1 -Full
```

Follow the fix hints for any failed checks.

## Metrics

View metrics:

```powershell
# Show learning stats
(Get-Content .qwen\skills\self-evolving-agent\knowledge\general-learnings.json | ConvertFrom-Json).Count

# Show backup count
(Get-ChildItem .qwen\skills\self-evolving-agent\backups\).Count

# View logs
Get-Content .qwen\skills\self-evolving-agent\logs\improvement-cycle.log -Tail 50
```

## Security

- All changes are backed up before applying
- Git integration for version control
- No external data transmission (offline-first)
- Respects .gitignore rules

## Performance

- Incremental updates (only changed files)
- Cached documentation with TTL
- Batch processing for efficiency
- Lazy loading for large knowledge bases

## Contributing

To extend this skill:

1. Add new scripts to `scripts/`
2. Document in `references/`
3. Update `SKILL.md`
4. Run `validate-self-skill.ps1`
5. Commit with descriptive message

## License

Part of the Steps to Recovery project.

---

**Maintained By:** Self-Evolving Agent System  
**Last Updated:** 2026-04-02
