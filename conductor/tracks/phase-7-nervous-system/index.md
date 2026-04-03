# Track: Sponsor Nervous System (Phase 7)

**Status:** 🔄 In Progress
**Started:** 2026-04-02
**Phase:** 7 of 12
**Depends on:** Phase 6 (Living AI Sponsor — partial dependency)

## Links

- **Plan:** `docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md`
- **Spec:** `docs/superpowers/specs/2026-04-02-sponsor-nervous-system-design.md`
- **Key files:** `lib/features/ai_companion/`, `lib/navigation/shell_screen.dart`

## Summary

Wire the sponsor into app behavior so it notices patterns and proactively reaches out — not just responds when the user opens chat.

**Signals the sponsor watches:**
- Days since last app open (silence detection)
- Check-in craving level patterns
- Journal frequency
- Step work engagement

**Outputs:**
- Amber badge on sponsor tab (unread sponsor message)
- Proactive message queued on specific triggers
- Feature-level prompts (journal, readings) suggesting sponsor check-in

## Current State

Signal architecture designed. Badge system partially wired. Feature hooks not yet implemented.

## Key Decisions Made

- Badge: amber dot on existing bottom nav tab (no new nav item)
- Proactive messages: queued in sponsor memory store, not push notifications (privacy)
- Silence threshold: 7 days triggers "haven't seen you" message
- High craving threshold: craving ≥ 7 on any check-in triggers sponsor attention
