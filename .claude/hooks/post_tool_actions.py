#!/usr/bin/env python3
"""Post-edit automation for Flutter repository hygiene."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any


def load_hook_input() -> dict[str, Any]:
    raw = sys.stdin.read().strip()
    if not raw:
        return {}

    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return {}

    return parsed if isinstance(parsed, dict) else {}


def resolve_file_path(tool_input: Any, project_root: Path) -> Path | None:
    if not isinstance(tool_input, dict):
        return None

    raw_path = tool_input.get("file_path")
    if not isinstance(raw_path, str) or not raw_path.strip():
        return None

    file_path = Path(raw_path)
    if not file_path.is_absolute():
        file_path = project_root / file_path

    return file_path.resolve(strict=False)


def run_quiet(command: list[str], cwd: Path) -> None:
    try:
        subprocess.run(
            command,
            cwd=str(cwd),
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        # If the command is missing, do not block the user workflow.
        return


def maybe_format_dart(file_path: Path, project_root: Path) -> None:
    if file_path.suffix != ".dart" or not file_path.exists():
        return

    run_quiet(["dart", "format", str(file_path)], project_root)


def maybe_pub_get(file_path: Path, project_root: Path) -> None:
    if file_path.name != "pubspec.yaml":
        return

    flutter_wrapper = project_root / "tool" / "flutterw.ps1"
    if flutter_wrapper.exists():
        powershell = shutil.which("pwsh") or shutil.which("powershell")
        if powershell:
            run_quiet(
                [
                    powershell,
                    "-NoProfile",
                    "-ExecutionPolicy",
                    "Bypass",
                    "-File",
                    str(flutter_wrapper),
                    "pub",
                    "get",
                ],
                project_root,
            )
            return

    run_quiet(["flutter", "pub", "get"], project_root)


def main() -> int:
    payload = load_hook_input()
    project_root = Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()).resolve(strict=False)
    tool_input = payload.get("tool_input", {})

    file_path = resolve_file_path(tool_input, project_root)
    if file_path is None:
        return 0

    maybe_format_dart(file_path, project_root)
    maybe_pub_get(file_path, project_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
