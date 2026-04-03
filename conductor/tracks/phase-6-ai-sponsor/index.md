# Track: Living AI Sponsor (Phase 6)

**Status:** 🔄 In Progress
**Started:** 2026-03-29
**Phase:** 6 of 12

## Links

- **Plan:** `docs/superpowers/plans/2026-03-22-living-ai-sponsor.md`
- **Spec:** `docs/superpowers/specs/2026-03-22-living-ai-sponsor-design.md`
- **Key files:** `lib/core/services/sponsor_service.dart`, `lib/core/models/sponsor_models.dart`, `lib/core/services/sponsor_memory_store.dart`, `lib/core/constants/sponsor_soul.dart`

## Summary

Replace the generic `AiService` chat with a living sponsor that:
- Has persistent, tiered memory (session → daily digest → long-term distilled)
- Has five relationship stages: New → Building → Trusted → Close → Deep
- Has a Soul Document guiding its voice, worldview, and response style
- Uses aggregated signals (not raw journal text) to understand user patterns
- Can proactively reach out (Phase 7)

## Current State

Core models and memory store built. Sponsor service partially wired. UI screens scaffolded but not complete.

## Blocking Issues

None currently.

## Key Decisions Made

- State: keep existing singletons, no Riverpod
- Data access: aggregated signals only, never raw journal/step text
- Identity: user-named + vibe chosen at setup
- Guardrails: invisible character traits, not legal disclaimers
- Backend: app → Recovery API → OpenClaw adapter (never direct to OpenClaw)
