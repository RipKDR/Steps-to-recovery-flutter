#!/usr/bin/env python3
"""Repository safety checks for Claude Code hooks."""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Iterable

EDIT_BLOCKED_PREFIXES = (
    "app/",
    "build/",
    ".dart_tool/",
    ".claude/worktrees/",
)

ALWAYS_BLOCKED_PATHS = {
    "android/local.properties",
}

SECRET_PATH_PATTERNS = (
    re.compile(r"(^|/)\.env($|\.)"),
    re.compile(r"\.jks$"),
    re.compile(r"\.keystore$"),
    re.compile(r"(^|/)google-services\.json$"),
    re.compile(r"(^|/)googleservice-info\.plist$"),
    re.compile(r"(^|/)key\.properties$"),
)


def load_hook_input() -> dict[str, Any]:
    raw = sys.stdin.read().strip()
    if not raw:
        return {}

    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return {}

    return parsed if isinstance(parsed, dict) else {}


def iter_path_values(value: Any) -> Iterable[str]:
    if isinstance(value, dict):
        for key, child in value.items():
            lowered = key.lower()
            if isinstance(child, str) and ("path" in lowered or lowered in {"file", "filename"}):
                yield child
            elif isinstance(child, (dict, list, tuple)):
                yield from iter_path_values(child)
    elif isinstance(value, (list, tuple)):
        for item in value:
            yield from iter_path_values(item)


def normalize_path(raw_path: str, project_root: Path) -> str:
    candidate = raw_path.strip().strip('"').strip("'")
    if not candidate:
        return ""

    path_obj = Path(candidate)
    if not path_obj.is_absolute():
        path_obj = (project_root / path_obj).resolve(strict=False)
    else:
        path_obj = path_obj.resolve(strict=False)

    try:
        relative = path_obj.relative_to(project_root.resolve(strict=False))
        return str(relative).replace("\\", "/").lower()
    except ValueError:
        return str(path_obj).replace("\\", "/").lower()


def is_secret_path(normalized_path: str) -> bool:
    return any(pattern.search(normalized_path) for pattern in SECRET_PATH_PATTERNS)


def check_path_rules(tool_name: str, tool_input: Any, project_root: Path) -> str | None:
    edit_mode = tool_name in {"Edit", "Write", "MultiEdit"}

    for raw_path in iter_path_values(tool_input):
        normalized = normalize_path(raw_path, project_root)
        if not normalized:
            continue

        if normalized in ALWAYS_BLOCKED_PATHS:
            return f"Blocked: `{raw_path}` is a local machine config file and should not be edited or read by Claude."

        if edit_mode and normalized.startswith(EDIT_BLOCKED_PREFIXES):
            return (
                f"Blocked: `{raw_path}` is inside a protected/generated area. "
                "Edit source files in the repo root project instead."
            )

        if is_secret_path(normalized):
            return f"Blocked: `{raw_path}` looks like a secrets file. Keep secrets out of agent sessions."

    return None


def check_bash_rules(tool_input: Any) -> str | None:
    if not isinstance(tool_input, dict):
        return None

    command = tool_input.get("command")
    if not isinstance(command, str):
        return None

    segments = re.split(r"(?:&&|\|\||;|\r?\n)", command)
    for segment in segments:
        candidate = segment.strip().lstrip("&").strip()
        if not candidate:
            continue

        if re.match(r"(?i)^flutter(?:\.bat|\.exe)?\b", candidate):
            return (
                "Blocked: direct `flutter` commands are disabled in this repo. "
                "Use `.\\tool\\flutterw.ps1 ...` to keep SDK resolution deterministic."
            )

    return None


def block_with_reason(reason: str) -> int:
    sys.stderr.write(reason + "\n")
    return 2


def main() -> int:
    payload = load_hook_input()
    tool_name = str(payload.get("tool_name", ""))
    tool_input = payload.get("tool_input", {})
    project_root = Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())

    if tool_name in {"Edit", "Write", "MultiEdit", "Read"}:
        reason = check_path_rules(tool_name, tool_input, project_root)
        if reason:
            return block_with_reason(reason)

    if tool_name == "Bash":
        reason = check_bash_rules(tool_input)
        if reason:
            return block_with_reason(reason)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
