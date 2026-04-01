---
name: steps-project-conventions
description: Enforce non-negotiable repository conventions for Steps to Recovery Flutter work.
user-invocable: false
---

# Steps Project Conventions

Use this skill whenever Claude is modifying code in this repository.

## Hard Rules

1. The runnable app is the repo root. Do not edit `app/` (snapshot only).
2. Use `.\tool\flutterw.ps1` for Flutter commands in this repo.
3. Keep business logic in services, not in widgets/screens.
4. Route sensitive user data through `DatabaseService` so encryption is preserved.
5. Use `LoggerService` instead of `print()`.
6. Before sign-off, run:
   - `.\tool\flutterw.ps1 analyze`
   - `.\tool\flutterw.ps1 test`

## Security Baseline

- Treat journal, inventory, sponsor, and recovery text as sensitive by default.
- Do not expose secrets from `.env`, local machine config, keystores, or platform secret files.
- Any sync path must preserve offline-first behavior and encrypted-at-rest assumptions.

## Review Baseline

When asked to review changes:
- Report findings first, ordered by severity.
- Include file and line references.
- Call out testing gaps if behavior changed without coverage.
