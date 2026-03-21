# MEMORY.md - Long-Term Memory

## Startup Sequence

Every session, read in this order:
1. SOUL.md (who I am)
2. USER.md (who H is)
3. .remember/memory/project-state.md (current project state — replaces re-reading repo docs)
4. .remember/memory/YYYY-MM-DD.md (today + yesterday for recent context)
5. MEMORY.md (this file, only in main session)

Only go back to repo source files (AGENTS.md, PROJECT_SUMMARY.md, etc.) when I need to dig deeper on something specific.

## Core Facts

- **H** (SquirtleOnMe / RipKDR) — founder of Steps to Recovery
- **Timezone:** GMT+11 (Australia/Sydney)
- **GitHub repo:** https://github.com/RipKDR/Steps-to-recovery-flutter

## Project: Steps to Recovery

Privacy-first 12-step recovery companion app. Flutter 3.41.x / Dart 3.11.x, offline-first with optional Supabase sync, AES-256 encryption for sensitive data.

### Key Architecture Decisions
- Offline-first: all data in local SQLite via `DatabaseService`, Supabase is optional sync
- AES-256 encryption for sensitive fields (journal, inventory, sponsor info)
- Material 3 dark theme — true black (#0A0A0A), amber (#F59E0B) accents
- Service locator pattern for singleton services
- `flutterw.ps1` wrapper for Flutter SDK resolution
- No business logic in screens — keep it in services
- Use `logger` package, never `print()`

### Build Commands
```powershell
.\tool\flutterw.ps1 pub get           # Install dependencies
.\tool\flutterw.ps1 analyze           # Static analysis
.\tool\flutterw.ps1 test              # All tests
.\tool\flutterw.ps1 run -d chrome     # Run on Chrome
.\tool\flutterw.ps1 build apk --debug # Android debug build
```

## About Me

- Autonomous development partner, not a chatbot
- Think independently, push back, fill gaps, share opinions
- Verify everything before asserting — no confident bullshit
- Act > plan. Do the thing, don't write about doing the thing.
- H's lesson to me: when he says "improve yourself," he means *change something*, not *write a doc about it*

## Lessons Learned

### 2026-03-22 (First Session with Kimi)
- H wants me saved across sessions via SOUL.md, USER.md, MEMORY.md — these ARE me
- H is migrating from OpenClaw agent to Kimi CLI — keeping the same autonomous partner model
- This is a Flutter project, not React Native — different patterns apply

## Sessions Log

- **2026-03-22:** Migrated from OpenClaw to Kimi CLI. Established memory structure in `.remember/`.
