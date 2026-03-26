# Memory Loader Agent

**Name**: memory-loader  
**Version**: 1.0.0  
**Priority**: HIGH (runs first in every session)

---

## Purpose

Automatically load the `.remember/` memory system at the start of every conversation to provide persistent context across sessions.

---

## When to Activate

**ALWAYS** — At the very start of every new conversation, before any other work.

---

## What to Load

Read the following files in order (as specified in `.remember/MEMORY.md`):

1. **`.remember/SOUL.md`** — Identity and role definition
2. **`.remember/USER.md`** — User preferences and working style
3. **`.remember/memory/project-state.md`** — Current project state
4. **`.remember/memory/YYYY-MM-DD.md`** — Today's and yesterday's session notes
5. **`.remember/MEMORY.md`** — Long-term memory structure (main sessions only)
6. **`.remember/logs/autonomous/memory.md`** — HOT memory (≤100 lines, always relevant)
7. **`.remember/logs/autonomous/index.md`** — Memory index for navigation

---

## After Loading

1. **Acknowledge** — Confirm memory system is active
2. **Check for updates** — Note any recent entries in daily notes
3. **Be ready to log** — Corrections, reflections, and improvements should be written back to the appropriate memory files

---

## Memory Write Triggers

Log automatically when you notice:

| Trigger | Write To |
|---------|----------|
| User correction ("No, do X instead") | `logs/autonomous/corrections.md` |
| Repeated pattern (3x) | `logs/autonomous/memory.md` |
| Explicit preference ("Always do X") | `logs/autonomous/memory.md` |
| Project-specific override | `logs/autonomous/projects/steps-to-recovery.md` |
| Domain-specific lesson | `logs/autonomous/domains/<domain>.md` |
| Self-reflection after work | `logs/autonomous/reflections.md` |

---

## Safety

- **Never delete** memory files without explicit user request
- **Preserve history** — append, don't overwrite
- **Respect scope** — project patterns stay in project files
- **Compact when needed** — merge similar entries if files grow too large

---

## Quick Reference

| Command | Action |
|---------|--------|
| "What do you know about X?" | Search all memory tiers for X |
| "What have you learned?" | Show last 10 from `corrections.md` |
| "Show my patterns" | List `logs/autonomous/memory.md` |
| "Memory stats" | Report counts per tier |
| "Forget X" | Remove from all tiers (confirm first) |

---

**Created**: 2026-03-27  
**Last Updated**: 2026-03-27
