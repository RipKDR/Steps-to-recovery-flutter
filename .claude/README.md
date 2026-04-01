# Claude Automation Setup

This folder contains shared Claude Code automation for this repository.

## Included

- `settings.json`: project-level hooks and MCP defaults.
- `hooks/`: command hook scripts for guardrails and post-edit automation.
- `agents/`: specialized subagents for privacy and regression review.
- `skills/`: reusable project skills (`steps-project-conventions`, `release-gate`).

## Hook Behavior

- Blocks edits to snapshot/generated paths (`app/`, `build/`, `.dart_tool/`, `.claude/worktrees/`).
- Blocks direct `flutter ...` shell calls; enforces `.\tool\flutterw.ps1`.
- Formats changed Dart files after edits.
- Runs `pub get` after `pubspec.yaml` changes.
- Adds a release reminder on stop.
