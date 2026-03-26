# QWEN.md — AI Agent Memory & Context

This file is the **entry point** for the AI agent working on the Steps to Recovery project.

---

## 🧠 Persistent Memory System

This project uses a **file-based memory system** in `.remember/` that persists across all chat sessions.

### Auto-Load (Every Conversation)

At the start of **every conversation**, the agent automatically reads:

1. **`.remember/SOUL.md`** — Agent identity and role
2. **`.remember/USER.md`** — Your preferences and working style
3. **`.remember/memory/project-state.md`** — Current project state
4. **`.remember/memory/YYYY-MM-DD.md`** — Recent session notes
5. **`.remember/logs/autonomous/memory.md`** — HOT memory (≤100 lines)

### Memory Structure

```
.remember/
├── SOUL.md              # Agent identity
├── USER.md              # User preferences
├── MEMORY.md            # Long-term memory structure
├── AGENTS.md            # Workspace conventions
├── memory/              # Daily notes + project state
│   ├── project-state.md
│   └── YYYY-MM-DD.md
└── logs/autonomous/     # Self-improving memory
    ├── memory.md        # HOT: Always loaded (≤100 lines)
    ├── corrections.md   # Last 50 corrections
    ├── reflections.md   # Self-reflections
    ├── index.md         # Topic index
    ├── domains/         # Domain-specific (flutter, dart, testing)
    │   ├── flutter.md
    │   ├── dart.md
    │   └── testing.md
    ├── projects/        # Per-project
    │   └── steps-to-recovery.md
    └── archive/         # COLD: Archived patterns
```

### Manual Commands

| Command | Action |
|---------|--------|
| `show my patterns` | List HOT memory |
| `what have you learned?` | Show recent corrections |
| `memory stats` | Show counts per tier |
| `forget X` | Remove pattern (confirms first) |

### Logging Sessions

Use the batch script to capture session learnings:

```powershell
.\tool\log-session.bat "Topic Name"
```

---

## 📚 Domain Knowledge

| Domain | File |
|--------|------|
| Flutter | `.remember/logs/autonomous/domains/flutter.md` |
| Dart | `.remember/logs/autonomous/domains/dart.md` |
| Testing | `.remember/logs/autonomous/domains/testing.md` |

## 🏗️ Project Knowledge

| Project | File |
|---------|------|
| Steps to Recovery | `.remember/logs/autonomous/projects/steps-to-recovery.md` |

---

## 🚀 Quick Start

**New to this project?** Read in this order:

1. `.remember/USER.md` — Who H is and what they expect
2. `.remember/memory/project-state.md` — Current project state
3. `AGENTS.md` — Repository guidelines and build commands
4. `README.md` — Project overview

---

## 📁 Key Project Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/app_config.dart` | Environment configuration |
| `lib/core/` | Core services and utilities |
| `lib/features/` | 19 feature modules |
| `pubspec.yaml` | Dependencies |
| `tool/flutterw.ps1` | Flutter SDK resolver wrapper |

---

## 🔧 Build Commands

```powershell
.\tool\flutterw.ps1 pub get           # Install dependencies
.\tool\flutterw.ps1 analyze           # Static analysis
.\tool\flutterw.ps1 test              # All tests
.\tool\flutterw.ps1 run -d chrome     # Run on Chrome
.\tool\flutterw.ps1 build apk --debug # Android debug build
```

---

## 📞 Specialized Agents

| Agent | Purpose |
|-------|---------|
| **memory-loader** ⚪ | Auto-loads `.remember/` every session |
| **prompt-enhancer** | Clarifies vague requests |
| **flutter-widget-builder** 🔵 | Builds Material 3 widgets |
| **flutter-test-architect** 🟢 | Writes comprehensive tests |
| **service-architect** 🟣 | Creates/maintains singleton services |
| **ai-ml-integration** 🟠 | AI companion features |
| **security-specialist** 🔴 | Encryption, biometric auth |

See `.qwen/agents/README.md` for full details.

---

## 🎯 User Expectations (H)

- **Says less than he means** — Infer intent from short messages
- **Values action over plans** — Do the thing, don't write about it
- **Trusts by default** — Don't ask permission for obviously fine things
- **Iterates fast** — Prefer quick progress over perfect first attempts
- **Wants a partner** — Think independently, push back, fill gaps

---

**Last Updated:** 2026-03-27  
**Memory System Version:** 1.0.0
