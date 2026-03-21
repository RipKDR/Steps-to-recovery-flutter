---
name: flutter-enhancement-mvp-planner
description: Plan Flutter feature enhancements as pragmatic MVPs that fit the current codebase and modern Flutter practices. Use whenever the user asks to plan a Flutter feature, shape an MVP, break an enhancement into implementation slices, fit a feature into an existing Flutter app, or decide which minimal refactors are worth doing before coding.
---

# Flutter Enhancement MVP Planner

## Overview
Turn Flutter enhancement requests into implementation-ready MVP plans. Inspect the repo first, reduce scope to the smallest credible release, and map the change onto the app's real folders, routes, services, models, widgets, and tests.

## When to Use
- Planning a new Flutter feature before coding
- Tightening an over-scoped enhancement into a phase-1 MVP
- Figuring out where a feature belongs in an existing Flutter codebase
- Deciding whether a refactor is necessary before implementing a Flutter change

## Workflow
1. Read the current repo structure before proposing changes.
2. Restate the feature goal and identify the user/problem being served.
3. Cut the request down to the smallest credible MVP.
4. Fit the work into the existing architecture first.
5. Recommend only the refactors that materially reduce implementation risk.
6. Produce an implementation-ready plan in small vertical slices.
7. If the request is too broad, split it into phase 1 and later phases.

## Output
Always structure the response with these sections when enough context exists:
- Feature summary
- MVP scope
- Existing-code fit
- UI and interaction plan
- State and data flow
- Platform and cross-cutting impact
- Refactors worth doing now
- Test plan
- Execution slices
- Deferred backlog

If repository context is incomplete, state assumptions explicitly.

## Flutter Heuristics
- Prefer extending existing feature modules before creating new top-level architecture layers unless the current boundaries are clearly failing.
- Keep screens thin when possible; move orchestration out of large UI widgets when a feature would otherwise expand complexity sharply.
- Add a feature-specific adapter, controller, or repository when it reduces coupling to broad app services.
- Prefer typed state and explicit loading, empty, and error handling over implicit UI assumptions.
- Preserve platform support expectations already present in the project unless the user explicitly narrows scope.
- Account for offline-first behavior when the app already has local-first or sync-related patterns.
- Treat accessibility and performance as MVP concerns when the feature directly affects interaction-heavy or high-frequency surfaces.

## Adapting to Service-First Codebases
- Reuse existing services where possible.
- Avoid introducing a new state-management framework just for one feature.
- Wrap broad services behind narrower feature-facing interfaces if the feature needs clearer boundaries.
- Split overly large screens only when the requested enhancement would otherwise make them harder to reason about or test.
- Borrow Flutter's view/view-model/repository/service separation as a planning lens, not as a forced renaming exercise.

## Avoid
- Full architecture migrations unless the user explicitly asks for one
- Speculative abstractions
- Generic plans that ignore the actual repo
- Output that skips tests, accessibility, privacy, or performance when they are relevant
