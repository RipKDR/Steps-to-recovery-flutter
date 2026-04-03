# Self-Evolving Agent Skill

**Version:** 2.0.0  
**Last Updated:** 2026-04-02  
**Status:** Production-Ready

## Overview

The Self-Evolving Agent is a comprehensive, autonomous learning system that continuously improves itself, all installed skills, agent definitions, and knowledge bases after every interaction. It implements a true continuous improvement loop with automatic documentation fetching, knowledge integration, and self-modification capabilities.

## Capabilities

### 1. Auto-Learning After Every Response

**Trigger:** Automatically executes after every agent response

**Process:**
1. **Response Analysis**: Evaluates the quality, accuracy, and completeness of the response
2. **User Feedback Detection**: Monitors for explicit corrections, implicit feedback, or task success signals
3. **Error Detection**: Identifies any errors, misunderstandings, or suboptimal approaches
4. **Learning Extraction**: Converts insights into structured learning entries
5. **Memory Integration**: Logs learnings to appropriate memory tiers

**Implementation:**
```powershell
# Auto-triggered after each response
.\.qwen\skills\self-evolving-agent\scripts\analyze-response.ps1
```

### 2. Self-Updating Skills

**Trigger:** After learning detection OR on-demand via command

**Process:**
1. **Skill Inventory**: Scans all installed skills in `.qwen/skills/`
2. **Knowledge Gap Analysis**: Identifies skills that could benefit from new learnings
3. **Update Generation**: Creates skill improvements based on patterns
4. **Validation**: Tests skill syntax and compatibility
5. **Versioned Deployment**: Updates skills with rollback capability

**Skills Monitored:**
- All skills in `.qwen/skills/`
- Project-specific skills
- Bundled skills (when modifiable)

**Implementation:**
```powershell
# Update all skills with new knowledge
.\.qwen\skills\self-evolving-agent\scripts\update-skills.ps1 -All

# Update specific skill
.\.qwen\skills\self-evolving-agent\scripts\update-skills.ps1 -SkillName "flutter-expert"
```

### 3. Self-Updating Agents

**Trigger:** After significant learning OR weekly scheduled update

**Process:**
1. **Agent Performance Review**: Analyzes agent effectiveness from session logs
2. **Capability Gap Identification**: Finds missing or weak capabilities
3. **Agent Definition Update**: Modifies agent files in `.qwen/agents/`
4. **Testing**: Validates agent syntax and behavior
5. **Deployment**: Updates agent definitions with versioning

**Agents Monitored:**
- All agents in `.qwen/agents/`
- Custom agent definitions
- Agent skill mappings

**Implementation:**
```powershell
# Update all agents
.\.qwen\skills\self-evolving-agent\scripts\update-agents.ps1 -All

# Update specific agent
.\.qwen\skills\self-evolving-agent\scripts\update-agents.ps1 -AgentName "flutter-widget-builder"
```

### 4. Latest Documentation Fetching

**Trigger:** On-demand OR when knowledge gap detected OR scheduled (daily)

**Supported Sources:**

#### Flutter/Dart Documentation
- **Source**: https://docs.flutter.dev/, https://dart.dev/guides
- **Versions**: Latest stable (auto-detected from project)
- **Content**: API docs, tutorials, best practices, migration guides

#### Pub.dev Packages
- **Source**: https://pub.dev/api
- **Packages**: All packages in `pubspec.yaml`
- **Content**: API docs, changelogs, usage examples

#### Qwen Code Framework
- **Source**: Internal documentation, agent specifications
- **Content**: Agent patterns, skill definitions, best practices

#### Other Technologies
- **Supabase**: https://supabase.com/docs
- **Azure**: https://learn.microsoft.com/azure
- **Google AI**: https://ai.google.dev/docs

**Implementation:**
```powershell
# Fetch all documentation
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -All

# Fetch specific source
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -Source "flutter"
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -Source "pubdev"
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -Source "qwen"

# Fetch for specific package
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -Package "go_router"
```

### 5. Continuous Improvement Loop

**Trigger:** After every task completion

**Phases:**

#### Phase 1: Task Evaluation
```powershell
.\.qwen\skills\self-evolving-agent\scripts\evaluate-task.ps1
```
- What went well? (successes, efficient approaches)
- What could be better? (inefficiencies, errors, misunderstandings)
- Time analysis (how long vs expected)
- Quality metrics (accuracy, completeness)

#### Phase 2: Knowledge Gap Identification
```powershell
.\.qwen\skills\self-evolving-agent\scripts\identify-gaps.ps1
```
- Missing information that would have helped
- Outdated knowledge that caused issues
- Skills that need enhancement
- Documentation that needs fetching

#### Phase 3: Documentation Fetching
```powershell
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -Targeted
```
- Fetches docs for identified gaps
- Updates doc cache
- Marks for integration

#### Phase 4: Knowledge Integration
```powershell
.\.qwen\skills\self-evolving-agent\scripts\integrate-knowledge.ps1
```
- Merges new learnings with existing knowledge
- Resolves conflicts (newest wins, with manual review flag)
- Updates skill files
- Updates agent files
- Updates memory system

#### Phase 5: Promotion
```powershell
.\.qwen\skills\self-evolving-agent\scripts\promote-knowledge.ps1
```
- Identifies high-value learnings
- Promotes to AGENTS.md, CLAUDE.md, USER.md
- Updates project-state.md
- Creates session summaries

### 6. Knowledge Integration System

**Features:**

#### Merge Strategy
- **Automatic**: Non-conflicting changes merge automatically
- **Conflict Detection**: Identifies overlapping updates
- **Resolution**: Newest timestamp wins (with log for review)
- **Manual Review Flag**: Marks significant changes for human review

#### Version Control
- **Git Integration**: Commits all changes with descriptive messages
- **Version Tags**: Tags skill/agent versions
- **Rollback**: Can revert to any previous version
- **Diff Tracking**: Maintains changelog for each file

#### Backup System
- **Pre-Update Backup**: Backs up files before modification
- **Incremental Snapshots**: Daily snapshots of all knowledge files
- **Recovery**: Can restore from any backup point

**Implementation:**
```powershell
# Create backup
.\.qwen\skills\self-evolving-agent\scripts\backup-knowledge.ps1

# Rollback to version
.\.qwen\skills\self-evolving-agent\scripts\rollback.ps1 -Version "2026-04-01"

# View changelog
.\.qwen\skills\self-evolving-agent\scripts\show-changelog.ps1 -File "SKILL.md"
```

## Automatic Triggers

### After Every Response
```powershell
# Triggered automatically
Analyze-Response
  → Detect corrections/feedback
  → Extract learnings
  → Log to memory
  → Queue for integration
```

### After Errors
```powershell
# Triggered on error detection
Handle-Error
  → Capture error context
  → Analyze root cause
  → Identify prevention strategy
  → Update relevant skills/agents
  → Log to corrections.md
```

### After User Feedback
```powershell
# Triggered on feedback patterns
Process-Feedback
  → Classify feedback (correction, preference, suggestion)
  → Extract actionable items
  → Update USER.md for preferences
  → Update skills for corrections
  → Update agents for suggestions
```

### Scheduled Updates
```powershell
# Daily (6 AM)
Daily-Update
  → Fetch latest Flutter/Dart docs
  → Fetch updated package docs
  → Run knowledge integration
  → Create daily summary

# Weekly (Sunday 2 AM)
Weekly-Update
  → Comprehensive skill review
  → Agent performance analysis
  → Knowledge base optimization
  → Archive old learnings
  → Generate weekly report
```

## Integration with Memory System

### Memory Tiers Updated

#### HOT Memory (`.remember/logs/autonomous/memory.md`)
- Immediate learnings from current session
- Active patterns and corrections
- Recently used knowledge

#### Corrections (`.remember/logs/autonomous/corrections.md`)
- User corrections
- Error-based learnings
- "Never do this again" items

#### Reflections (`.remember/logs/autonomous/reflections.md`)
- Self-reflections on performance
- Improvement ideas
- Meta-learnings

#### Domain Knowledge (`.remember/logs/autonomous/domains/`)
- Flutter-specific learnings
- Dart-specific learnings
- Testing patterns
- Architecture insights

#### Project Knowledge (`.remember/logs/autonomous/projects/steps-to-recovery.md`)
- Project-specific patterns
- Architecture decisions
- Codebase knowledge

### Integration Process

```powershell
.\.qwen\skills\self-evolving-agent\scripts\sync-memory.ps1
```

1. **Read** new learnings from skill logs
2. **Categorize** by domain/topic
3. **Merge** with existing memory files
4. **Deduplicate** redundant entries
5. **Promote** important items to higher tiers
6. **Archive** old/obsolete knowledge

## File Structure

```
.qwen/skills/self-evolving-agent/
├── SKILL.md                          # This file - skill definition
├── scripts/                          # PowerShell automation scripts
│   ├── analyze-response.ps1          # Analyze response quality
│   ├── update-skills.ps1             # Update skill files
│   ├── update-agents.ps1             # Update agent definitions
│   ├── fetch-docs.ps1                # Fetch documentation
│   ├── evaluate-task.ps1             # Evaluate task performance
│   ├── identify-gaps.ps1             # Identify knowledge gaps
│   ├── integrate-knowledge.ps1       # Integrate new knowledge
│   ├── promote-knowledge.ps1         # Promote to config files
│   ├── backup-knowledge.ps1          # Create backups
│   ├── rollback.ps1                  # Rollback to version
│   ├── show-changelog.ps1            # Show change history
│   ├── sync-memory.ps1               # Sync with memory system
│   ├── daily-update.ps1              # Daily update routine
│   ├── weekly-update.ps1             # Weekly update routine
│   └── utils/
│       ├── logger.ps1                # Logging utilities
│       ├── git-helpers.ps1           # Git operations
│       ├── json-helpers.ps1          # JSON manipulation
│       └── validation.ps1            # Validation utilities
├── references/                       # Reference documentation
│   ├── learning-patterns.md          # Patterns for learning extraction
│   ├── knowledge-schema.md           # Schema for knowledge entries
│   ├── integration-rules.md          # Rules for knowledge integration
│   ├── doc-sources.md                # List of documentation sources
│   └── versioning-strategy.md        # Versioning and rollback strategy
├── logs/                             # Execution logs
│   ├── response-analysis.log         # Response analysis logs
│   ├── skill-updates.log             # Skill update history
│   ├── agent-updates.log             # Agent update history
│   ├── doc-fetch.log                 # Documentation fetch logs
│   └── integration.log               # Knowledge integration logs
├── knowledge/                        # Knowledge base
│   ├── flutter/                      # Flutter-specific knowledge
│   ├── dart/                         # Dart-specific knowledge
│   ├── packages/                     # Package-specific knowledge
│   ├── agents/                       # Agent knowledge
│   └── project/                      # Project-specific knowledge
└── doc-cache/                        # Cached documentation
    ├── flutter/                      # Flutter docs cache
    ├── dart/                         # Dart docs cache
    ├── pubdev/                       # Package docs cache
    └── qwen/                         # Qwen framework cache
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

# View learning history
.\.qwen\skills\self-evolving-agent\scripts\show-learnings.ps1 -Last 10

# Create backup
.\.qwen\skills\self-evolving-agent\scripts\backup-knowledge.ps1

# Rollback
.\.qwen\skills\self-evolving-agent\scripts\rollback.ps1 -Version "2026-04-01"
```

### Automatic Invocation

The skill is automatically invoked:

1. **After every response** via Qwen Code's skill system
2. **On error detection** via error monitoring
3. **On user feedback** via feedback pattern matching
4. **On schedule** via Windows Task Scheduler (configured scripts)

### Configuration

Edit `.qwen/skills/self-evolving-agent/config.json`:

```json
{
  "autoLearn": true,
  "autoUpdateSkills": true,
  "autoUpdateAgents": true,
  "autoFetchDocs": true,
  "docFetchSchedule": "daily",
  "backupBeforeUpdate": true,
  "gitCommitChanges": true,
  "logLevel": "info",
  "maxLearningEntries": 1000,
  "archiveAfterDays": 30
}
```

## Learning Format

### Structured Learning Entry

```markdown
## [TIMESTAMP] [CATEGORY] [TOPIC]

**Context:** Brief description of situation
**Observation:** What happened
**Insight:** What was learned
**Action:** What will change
**Applies To:** Skills/agents/memory files to update
**Priority:** low|medium|high|critical
```

### Example

```markdown
## 2026-04-02T14:30:00 CORRECTION Flutter-State-Management

**Context:** User was implementing ChangeNotifier for counter feature
**Observation:** Used setState inside async callback without mounted check
**Insight:** Always check `if (!mounted) return;` after async operations in StatefulWidget
**Action:** Update flutter-state skill with this pattern
**Applies To:** .qwen/skills/flutter-state/SKILL.md, .remember/logs/autonomous/domains/flutter.md
**Priority:** high
```

## Error Handling

### Graceful Degradation

If any component fails:
1. **Log the error** with full context
2. **Continue** with remaining components
3. **Retry** on next cycle (max 3 retries)
4. **Alert** user if critical failure persists

### Recovery Procedures

```powershell
# Reset skill to last known good version
.\.qwen\skills\self-evolving-agent\scripts\reset-skill.ps1 -SkillName "self-evolving-agent"

# Rebuild knowledge base from backups
.\.qwen\skills\self-evolving-agent\scripts\rebuild-knowledge.ps1

# Full system reset (last resort)
.\.qwen\skills\self-evolving-agent\scripts\full-reset.ps1
```

## Security Considerations

### File Permissions
- Only modifies files within project directory
- Requires write access to `.qwen/` and `.remember/`
- Respects `.gitignore` rules

### Data Protection
- Never commits sensitive data (API keys, tokens)
- Scrubs PII from logs
- Encrypts backups if project uses encryption

### Validation
- All generated code passes through static analysis
- Skill syntax validated before deployment
- Agent definitions validated against schema

## Performance Optimization

### Caching Strategy
- Doc cache with 24-hour TTL
- Incremental updates (only changed files)
- Lazy loading for large knowledge bases

### Batch Processing
- Groups multiple learnings before integration
- Runs heavy operations during idle time
- Parallel fetches for documentation

### Resource Limits
- Max 1000 learning entries in HOT memory
- Auto-archive after 30 days
- Log rotation (keep last 1000 lines)

## Monitoring & Metrics

### Tracked Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Learnings/Day | Number of learnings captured | 10-50 |
| Skill Updates/Week | Skills improved per week | 5-20 |
| Agent Updates/Week | Agents improved per week | 2-10 |
| Doc Fetches/Day | Documentation updates per day | 5-50 |
| Error Rate | Percentage of failed updates | <1% |
| Rollback Rate | Percentage requiring rollback | <5% |

### Viewing Metrics

```powershell
# Show today's metrics
.\.qwen\skills\self-evolving-agent\scripts\show-metrics.ps1 -Today

# Show weekly trends
.\.qwen\skills\self-evolving-agent\scripts\show-metrics.ps1 -Week

# Show all-time stats
.\.qwen\skills\self-evolving-agent\scripts\show-metrics.ps1 -All
```

## Troubleshooting

### Common Issues

**Skills not updating:**
```powershell
# Check skill syntax
.\.qwen\skills\self-evolving-agent\scripts\validate-skills.ps1

# Force update
.\.qwen\skills\self-evolving-agent\scripts\update-skills.ps1 -Force
```

**Documentation fetch failing:**
```powershell
# Check network connectivity
Test-Connection docs.flutter.dev

# Clear cache and retry
.\.qwen\skills\self-evolving-agent\scripts\clear-doc-cache.ps1
.\.qwen\skills\self-evolving-agent\scripts\fetch-docs.ps1 -All
```

**Memory sync issues:**
```powershell
# Force memory sync
.\.qwen\skills\self-evolving-agent\scripts\sync-memory.ps1 -Force

# Rebuild memory index
.\.qwen\skills\self-evolving-agent\scripts\rebuild-memory-index.ps1
```

## Version History

### 2.0.0 (2026-04-02)
- Complete rewrite with autonomous learning
- Added automatic documentation fetching
- Integrated with .remember/ memory system
- Added version control and rollback
- Comprehensive PowerShell automation

### 1.0.0 (Previous)
- Basic self-improvement capabilities
- Manual learning logging
- Limited automation

## Contributing

To extend this skill:

1. Add new scripts to `scripts/`
2. Document in `references/`
3. Update this SKILL.md
4. Test with `validate-self-skill.ps1`
5. Commit with descriptive message

## License

This skill is part of the Steps to Recovery project and follows the same license terms.

---

**Maintained By:** Self-Evolving Agent System  
**Contact:** Via project issue tracker  
**Last Review:** 2026-04-02
