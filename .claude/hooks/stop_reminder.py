#!/usr/bin/env python3
"""Adds a consistent release reminder when Claude tries to stop."""

from __future__ import annotations

import json


def main() -> int:
    message = {
        "systemMessage": (
            "Before shipping, run `.\\tool\\flutterw.ps1 analyze` and "
            "`.\\tool\\flutterw.ps1 test` (or invoke `/release-gate`)."
        )
    }
    print(json.dumps(message))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
