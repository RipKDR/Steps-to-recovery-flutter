---
name: release-gate
description: Run release-readiness checks for Steps to Recovery and return a go/no-go summary.
disable-model-invocation: true
---

# Release Gate

Use this skill before merge, release, or "done" claims.

## Commands

Run from repository root:

```powershell
.\tool\flutterw.ps1 analyze
.\tool\flutterw.ps1 test
```

Optional build validation when requested or when platform code changed:

```powershell
.\tool\flutterw.ps1 build apk --debug
```

## Report Format

Return:
1. `Status`: `GO` or `NO-GO`
2. `Checks`: pass/fail for analyze, tests, and build (if run)
3. `Blocking Issues`: concise list with file references
4. `Next Action`: single highest-value action

## Decision Rule

- `GO` only if all required checks pass.
- `NO-GO` if analyze or tests fail.
