---
name: meta-systems-hub
slug: meta-systems-hub
version: 1.0.0
description: Central coordination hub for autonomous code health, security enhancement, and test coverage systems. Integrates with GitHub Actions, self-evolving-agent, and dependabot to provide local pre-checks and continuous improvement.
metadata: {"emoji": "🎯", "requires": {"bins": ["flutter", "git"]}}
---

# Meta-Systems Hub

Central coordination for autonomous meta-capabilities that keep your codebase healthy, secure, and well-tested.

## Overview

The Meta-Systems Hub integrates with your existing CI/CD and self-evolving-agent to provide:

1. **Local Pre-Checks** - Catch issues before push (faster feedback than CI)
2. **Auto-Fix Capabilities** - Safely fix lint, imports, deprecated APIs
3. **Security Enhancement** - Local security scanning before push
4. **Test Generation** - Autonomous test creation and maintenance
5. **Unified Reporting** - Single dashboard for all meta-systems

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions (Existing)                      │
│  - ci.yml: Build, test, analyze on push                     │
│  - pr_check.yml: PR validation                              │
│  - security.yml: Security scanning                          │
│  - dependabot: Dependency updates                           │
└────────────────────┬────────────────────────────────────────┘
                     │ Runs AFTER push
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Meta-Systems Hub (NEW)                         │
│  Runs LOCALLY before push (faster feedback)                 │
│                                                             │
│  ┌──────────────────────────────────────────────┐           │
│  │ Code Health Module                           │           │
│  │ - Predictive issue detection                 │           │
│  │ - Auto-fix safe issues                       │           │
│  │ - Code smell detection                       │           │
│  └──────────────────────────────────────────────┘           │
│  ┌──────────────────────────────────────────────┐           │
│  │ Security Plus Module                         │           │
│  │ - Local security scanning                    │           │
│  │ - Encryption audit                           │           │
│  │ - PII leak detection                         │           │
│  └──────────────────────────────────────────────┘           │
│  ┌──────────────────────────────────────────────┐           │
│  │ Test Coverage Module                         │           │
│  │ - Auto-generate tests                        │           │
│  │ - Maintain coverage threshold                │           │
│  └──────────────────────────────────────────────┘           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Feeds learnings to
                     ↓
┌─────────────────────────────────────────────────────────────┐
│         Self-Evolving Agent (Existing)                      │
│  - Stores learnings                                         │
│  - Updates skills/agents                                    │
│  - Fetches docs                                             │
└─────────────────────────────────────────────────────────────┘
```

## Modules

### 1. Code Health Module

**Location:** `modules/code-health/`

**Purpose:** Self-healing code + predictive issue detection

**Scripts:**
- `analyze-with-context.ps1` - flutter analyze + historical patterns
- `predict-issues.ps1` - Catch issues before they happen
- `auto-fix-safe.ps1` - Auto-fix lint, imports, deprecated APIs
- `detect-code-smells.ps1` - Long methods, God classes, coupling
- `verify-with-tests.ps1` - Run relevant tests after fixes
- `generate-fix-pr.ps1` - Create GitHub PR for review

**Auto-Fix Categories:**
| Category | Auto-Fix? | Human Review? |
|----------|-----------|---------------|
| Missing imports | ✅ Yes | ❌ No |
| Unused variables | ✅ Yes | ❌ No |
| Deprecated APIs | ✅ Yes | ❌ No |
| Lint violations | ✅ Yes | ❌ No |
| Refactoring suggestions | ❌ No | ✅ Yes |
| Architecture changes | ❌ No | ✅ Yes |

**Usage:**
```powershell
# Analyze code
.\.qwen\skills\meta-systems-hub\modules\code-health\scripts\analyze-with-context.ps1

# Auto-fix safe issues
.\.qwen\skills\meta-systems-hub\modules\code-health\scripts\auto-fix-safe.ps1 -Category "lint,imports,unused"

# Detect code smells
.\.qwen\skills\meta-systems-hub\modules\code-health\scripts\detect-code-smells.ps1
```

---

### 2. Security Plus Module

**Location:** `modules/security-plus/`

**Purpose:** Enhances existing security.yml with local scanning

**Scripts:**
- `local-security-scan.ps1` - Pre-push security check
- `encryption-audit.ps1` - Validate AES-256 implementation
- `storage-privacy-scan.ps1` - Detect plaintext sensitive data
- `dependency-audit.ps1` - Extends dependabot locally
- `pii-leak-detector.ps1` - Find potential PII exposure
- `rls-policy-checker.ps1` - Validate Supabase RLS policies
- `compliance-generator.ps1` - Generate compliance reports

**Security Checks:**
- ✅ Encryption implementation audit (AES-256, key storage)
- ✅ Sensitive data storage scan (no plaintext journal/inventory)
- ✅ PII leak detection (phone numbers, emails in logs)
- ✅ RLS policy validation (Supabase security)
- ✅ Pre-push security gate

**Usage:**
```powershell
# Full security scan
.\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\local-security-scan.ps1 -Full

# Encryption audit
.\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\encryption-audit.ps1

# PII leak detection
.\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\pii-leak-detector.ps1
```

---

### 3. Test Coverage Module

**Location:** `modules/test-coverage/`

**Purpose:** Autonomous test generation and maintenance

**Scripts:**
- `coverage-analyzer.ps1` - Identify untested code
- `generate-unit-tests.ps1` - Auto-generate from code
- `generate-widget-tests.ps1` - Auto-generate screen tests
- `generate-golden-tests.ps1` - Visual regression tests
- `update-mocks.ps1` - Keep mocks in sync
- `coverage-report.ps1` - Generate coverage reports

**Features:**
- Detects new features without tests
- Generates tests from code analysis
- Maintains 80%+ coverage threshold
- Auto-updates mocks when code changes

**Usage:**
```powershell
# Analyze coverage
.\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\coverage-analyzer.ps1

# Generate tests for uncovered files
.\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\generate-unit-tests.ps1 -Target "uncovered"

# Generate widget tests
.\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\generate-widget-tests.ps1 -Screen "HomeScreen"
```

---

## Hub Commands

### Unified Commands

```powershell
# Run all scans
.\.qwen\skills\meta-systems-hub\scripts\run-all-scans.ps1

# Daily health report
.\.qwen\skills\meta-systems-hub\scripts\daily-health-report.ps1

# Pre-commit enhanced check
.\.qwen\skills\meta-systems-hub\scripts\pre-commit-enhanced.ps1

# Meta dashboard
.\.qwen\skills\meta-systems-hub\scripts\meta-dashboard.ps1
```

### Module-Specific Commands

```powershell
# Code Health
.\.qwen\skills\meta-systems-hub\modules\code-health\scripts\analyze-with-context.ps1
.\.qwen\skills\meta-systems-hub\modules\code-health\scripts\auto-fix-safe.ps1
.\.qwen\skills\meta-systems-hub\modules\code-health\scripts\predict-issues.ps1

# Security Plus
.\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\local-security-scan.ps1
.\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\encryption-audit.ps1
.\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\pii-leak-detector.ps1

# Test Coverage
.\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\coverage-analyzer.ps1
.\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\generate-unit-tests.ps1
.\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\coverage-report.ps1
```

---

## Integration with Existing Systems

### GitHub Actions

The hub **complements** (not replaces) your existing CI/CD:

| GitHub Action | Hub Enhancement |
|---------------|-----------------|
| `ci.yml` (build, test, analyze) | Local pre-checks before push |
| `pr_check.yml` (PR validation) | Local PR simulation |
| `security.yml` (security scan) | Pre-push security gate |
| `dependabot` (dependency updates) | Local compatibility testing |

### Self-Evolving Agent

The hub feeds learnings to `self-evolving-agent`:

```
Hub Scan → Detects Issue → Auto-Fixes → Logs Learning → Self-Evolving Agent Updates Skills
```

All learnings are stored in:
- `.qwen/skills/meta-systems-hub/logs/`
- `.remember/logs/autonomous/` (via sync)

### Dependabot

The hub enhances dependabot by:
- Testing dependency updates locally before merging
- Checking compatibility with your codebase
- Running tests with new versions
- Generating migration notes

---

## Configuration

Edit `.qwen/skills/meta-systems-hub/config.json`:

```json
{
  "enabled": true,
  "modules": {
    "codeHealth": {
      "enabled": true,
      "autoFix": true,
      "autoFixCategories": ["lint", "imports", "unused", "deprecated"],
      "requireApprovalFor": ["refactor", "architecture"],
      "preCommitCheck": true,
      "maxFixesPerRun": 10,
      "backupBeforeFix": true,
      "runTestsAfterFix": true
    },
    "securityPlus": {
      "enabled": true,
      "prePushCheck": true,
      "encryptionAudit": true,
      "piiDetection": true,
      "rlsCheck": true,
      "complianceReport": true,
      "failOnCritical": true
    },
    "testCoverage": {
      "enabled": true,
      "autoGenerate": true,
      "minCoverage": 80,
      "generateGoldenTests": true,
      "updateMocksAutomatically": true
    }
  },
  "integration": {
    "selfEvolvingAgent": true,
    "githubActions": true,
    "dependabot": true
  },
  "reporting": {
    "dailyReport": true,
    "dailyReportTime": "06:00",
    "reportLevel": "info",
    "outputFormat": "console"
  },
  "safety": {
    "gitStashBeforeFix": true,
    "rollbackOnTestFailure": true,
    "auditLog": true,
    "requireConfirmationFor": ["security", "architecture"]
  }
}
```

---

## Dashboard Output

```powershell
# Run dashboard
.\.qwen\skills\meta-systems-hub\scripts\meta-dashboard.ps1

# Example output:
╔════════════════════════════════════════════════════════════╗
║            Meta-Systems Dashboard                          ║
╚════════════════════════════════════════════════════════════╝

Code Health:        ✓ Excellent (98/100)
  Issues Found:     3 (all auto-fixed)
  Code Smells:      0
  Tech Debt:        Low

Security Status:    ✓ All Clear
  Encryption:       ✓ Valid (AES-256)
  PII Leaks:        0 detected
  RLS Policies:     ✓ All valid

Test Coverage:      78% (Target: 80%)
  New Tests Needed: 2 files
  Last Generated:   2026-04-02

CI/CD Status:       ✓ All passing
  Last Build:       Success
  Dependabot:       2 updates pending

Next Actions:
  - Generate tests for 2 new files
  - Review 2 dependabot PRs
```

---

## Safety Guarantees

- ✅ **Pre-Commit Check** - Catches issues before commit
- ✅ **Pre-Push Check** - Security scan before push
- ✅ **Auto-Fix Limits** - Only safe fixes (lint, imports, unused)
- ✅ **PR for Risky Changes** - Architecture/refactoring → human review
- ✅ **Test Verification** - Run tests after every auto-fix
- ✅ **Backup Before Fix** - Git stash before modifications
- ✅ **Rollback Support** - Revert if tests fail
- ✅ **Audit Trail** - All changes logged with reasoning

---

## Reporting

### Daily Report (6 AM)

```powershell
# Automatic daily report
.\.qwen\skills\meta-systems-hub\scripts\daily-health-report.ps1

# Example output:
╔════════════════════════════════════════╗
║   Daily Health Report - 2026-04-03   ║
╚════════════════════════════════════════╝

Issues Found:     12
Issues Fixed:     8
Issues Pending:   4 (require review)

Security Status:  ✓ All Clear
Dependencies:     2 updates available
Test Coverage:    78% (+2% from yesterday)

Top Issues:
1. Missing mounted check (3 occurrences)
2. Unused import (2 occurrences)
3. Long method: database_service.dart:245
```

### On-Demand Reports

```powershell
# Code health report
.\.qwen\skills\meta-systems-hub\modules\code-health\reports\code-health-report.ps1

# Security report
.\.qwen\skills\meta-systems-hub\modules\security-plus\reports\security-report.ps1

# Test coverage report
.\.qwen\skills\meta-systems-hub\modules\test-coverage\reports\coverage-report.ps1
```

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Code Health Score** | 95%+ | Lint violations / 1000 LOC |
| **Issues Prevented** | 90%+ | Caught pre-commit vs post-push |
| **Auto-Fix Rate** | 80%+ | Safe fixes applied automatically |
| **Security Compliance** | 100% | Critical issues = 0 |
| **Test Coverage** | 80%+ | Line coverage percentage |
| **CI Pass Rate** | 98%+ | First-time pass on GitHub Actions |
| **Time Saved** | 5+ hrs/week | Manual code review time |

---

## Troubleshooting

### Scripts won't run

Check PowerShell execution policy:

```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Git not available

Install Git for Windows: https://git-scm.com/download/win

### Flutter not found

Ensure Flutter is in PATH:

```powershell
flutter doctor
```

### Validation fails

Run validation with full checks:

```powershell
.\.qwen\skills\meta-systems-hub\scripts\validate-hub.ps1 -Full
```

Follow the fix hints for any failed checks.

---

## File Structure

```
.qwen/skills/meta-systems-hub/
├── SKILL.md                          # This file
├── README.md                         # User guide
├── config.json                       # Configuration
├── scripts/                          # Hub coordination
│   ├── run-all-scans.ps1
│   ├── daily-health-report.ps1
│   ├── pre-commit-enhanced.ps1
│   ├── meta-dashboard.ps1
│   └── integrate-with-github.ps1
├── modules/
│   ├── code-health/
│   │   ├── scripts/
│   │   │   ├── analyze-with-context.ps1
│   │   │   ├── predict-issues.ps1
│   │   │   ├── auto-fix-safe.ps1
│   │   │   ├── detect-code-smells.ps1
│   │   │   ├── verify-with-tests.ps1
│   │   │   └── generate-fix-pr.ps1
│   │   └── reports/
│   └── security-plus/
│   │   ├── scripts/
│   │   │   ├── local-security-scan.ps1
│   │   │   ├── encryption-audit.ps1
│   │   │   ├── storage-privacy-scan.ps1
│   │   │   ├── dependency-audit.ps1
│   │   │   ├── pii-leak-detector.ps1
│   │   │   ├── rls-policy-checker.ps1
│   │   │   └── compliance-generator.ps1
│   │   └── reports/
│   └── test-coverage/
│       ├── scripts/
│       │   ├── coverage-analyzer.ps1
│       │   ├── generate-unit-tests.ps1
│       │   ├── generate-widget-tests.ps1
│       │   ├── generate-golden-tests.ps1
│       │   ├── update-mocks.ps1
│       │   └── coverage-report.ps1
│       └── reports/
├── references/
│   ├── integration-guide.md
│   ├── safety-protocols.md
│   └── troubleshooting.md
└── logs/
    ├── scan-history.log
    ├── auto-fix.log
    └── security-audit.log
```

---

**Version:** 1.0.0  
**Created:** 2026-04-02  
**Status:** In Development  
**Integration:** Self-Evolving Agent, GitHub Actions, Dependabot
