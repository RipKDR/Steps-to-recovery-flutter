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

## Planning Style
- Default to a complete planning response in chat.
- Only suggest or generate a file when the user explicitly asks for one.
- Keep the plan pragmatic, repo-aware, and specific enough to implement without drifting into greenfield advice.

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

- Feature summary: explain what is being built, who it serves, and the user or product problem it solves.
- MVP scope: separate in-scope behavior, out-of-scope behavior, and explicitly deferred follow-ups; explain why the cuts are being made when that is not obvious.
- Existing-code fit: map the change onto the current repo's feature folders, routes, services, models, widgets, and tests; state assumptions instead of inventing certainty.
- UI and interaction plan: cover affected screens or widgets, loading, empty, error, and success states, navigation changes, validation or form needs, and responsive or platform-specific considerations when relevant.
- State and data flow: describe the source of truth, async boundaries, persistence and sync touchpoints, transformation points, error propagation, and retry or offline behavior when relevant.
- Platform and cross-cutting impact: cover only what applies from storage, sync, notifications, permissions, analytics or telemetry, accessibility, performance, privacy, and security.
- Refactors worth doing now: recommend only changes that materially reduce MVP delivery risk; include a short reason for each refactor, or explicitly say none are justified.
- Test plan: describe the smallest effective mix of unit tests for logic and transformations, widget tests for UI states and interactions, and targeted integration coverage for high-risk flows.
- Execution slices: break the work into small vertical slices that are independently deliverable and verifiable.
- Deferred backlog: capture intentionally cut work so it is not lost.

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
- Reuse existing routing, persistence, notification, and service patterns before proposing new layers.

## Avoid
- Full architecture migrations unless the user explicitly asks for one
- Speculative abstractions
- Generic plans that ignore the actual repo
- Output that skips tests, accessibility, privacy, or performance when they are relevant
- Recommending Riverpod, Bloc, Provider, or another state-management package unless the repo already uses it or the user explicitly asks for it
