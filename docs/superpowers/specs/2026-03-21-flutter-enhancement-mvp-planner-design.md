# Flutter Enhancement MVP Planner Skill Design

Date: 2026-03-21
Status: Draft approved for implementation planning
Proposed skill name: `flutter-enhancement-mvp-planner`

## Goal

Create a reusable Codex skill that plans Flutter feature enhancements as small, shippable MVPs. The skill should align with modern Flutter practices while staying pragmatic in existing codebases that already use service-heavy or mixed architectures.

The skill is meant to improve planning quality before implementation. It should help reduce scope, fit features into the current app structure, surface real architectural impact, and produce an implementation-ready breakdown without forcing unnecessary rewrites.

## Why This Skill

Flutter enhancement requests often fail in one of two ways:

1. The plan is too shallow and ignores routing, state, persistence, async flows, testing, accessibility, or platform concerns.
2. The plan is too idealized and recommends architecture churn that is not justified by the requested MVP.

This skill should sit between those extremes. It should recommend modern structure and clean boundaries, but only push refactors when they materially reduce feature risk, complexity, or regression cost.

## Design Decisions

### Reusability

The skill should be reusable across Flutter apps.

It should not be hard-coded to this repository, but it must include explicit guidance for adapting to existing service-first codebases like `Steps-to-recovery-flutter`, where the correct move is often to extend existing services with thinner feature-level boundaries instead of introducing a full architectural reset.

### Planning Style

The skill should be chat-first.

Its default output should be a complete planning response in chat. It may suggest or generate a file only when the user explicitly asks for one.

### Scope Behavior

The skill should be pragmatic about MVP scope.

It should reduce requests to the smallest credible release, clearly separate in-scope versus deferred work, and explain why deferred items are being cut. It should avoid both passive over-scoping and overly aggressive trimming that makes the MVP useless.

### Architecture Guidance

The skill should recommend modern Flutter patterns without forcing a preferred state-management library.

It should encourage:

- feature-first organization
- clear boundaries between UI, state orchestration, domain logic, and persistence/integration code
- typed models and explicit async/error states
- reusable widgets where reuse is real, not speculative
- layered testing

It should not force Riverpod, Bloc, Provider, or another library unless the repository already uses it or the user explicitly asks for it.

It should align conceptually with Flutter's current architecture guidance around separating UI concerns from orchestration and data concerns, while adapting that guidance to the naming and structure already present in the repository.

### Enhancement Coverage

The skill should cover both user-facing and technical enhancements when they materially affect MVP delivery.

That includes:

- UI and navigation changes
- state and data flow
- local persistence and remote sync touchpoints
- notifications and permissions
- accessibility
- performance
- privacy and security
- testing strategy
- minimal refactors justified by feature impact

## Triggering

The skill should trigger when the user asks to:

- plan a Flutter feature
- break down an MVP
- shape or refine an enhancement before implementation
- decide how a feature should fit into an existing Flutter codebase
- identify the minimal refactors needed to support a feature cleanly

The description should be somewhat pushy so the skill under-triggers less often. It should mention Flutter features, MVP planning, enhancement planning, implementation breakdowns, architecture-fit questions, and repo adaptation for existing mobile codebases.

## Required Workflow

When triggered, the skill should do the following:

1. Inspect current repo context before proposing changes.
2. Identify the smallest credible MVP.
3. Fit the work into the existing Flutter structure first.
4. Call out only the refactors that are worth doing now.
5. Produce an implementation-ready breakdown that can be executed in small vertical slices.

If the request is too broad for one MVP, the skill should explicitly split it into a phase-1 release and later phases instead of returning an oversized first plan.

The skill should not jump straight into greenfield advice if the repository already provides folders, services, routes, or patterns that can absorb the change.

## Output Contract

The skill should produce a structured plan with the following sections.

### 1. Feature Summary

Explain what is being built, who it serves, and the user or product problem being solved.

### 2. MVP Scope

List:

- in-scope behavior
- out-of-scope behavior
- explicitly deferred follow-ups

### 3. Existing-Code Fit

Map the work onto the current codebase:

- feature folders
- routes
- services
- models
- widgets
- tests

If context is incomplete, the skill should state assumptions rather than inventing certainty.

### 4. UI and Interaction Plan

Describe:

- screens or widgets affected
- loading, empty, error, and success states
- navigation changes
- form or validation requirements
- responsive or platform-specific considerations when relevant

### 5. State and Data Flow

Describe:

- source of truth
- async boundaries
- persistence and sync effects
- transformation points
- error propagation
- retry or offline behavior when relevant

### 6. Platform and Cross-Cutting Impact

Cover only what applies:

- storage
- sync
- notifications
- permissions
- analytics or telemetry
- accessibility
- performance
- privacy and security

### 7. Refactors Worth Doing Now

Recommend only structural changes that meaningfully improve the delivery of the requested MVP. Each recommended refactor should include a short reason. If no refactor is justified, say so.

### 8. Test Plan

Outline the smallest effective test mix:

- unit tests for logic and transformations
- widget tests for UI states and interactions
- targeted integration coverage for high-risk flows

The guidance should align with Flutter’s standard testing pyramid: many unit and widget tests, plus fewer higher-cost integration tests for key end-to-end paths.

### 9. Execution Slices

Break the work into small, vertically deliverable chunks. Each slice should be independently implementable and verifiable.

### 10. Deferred Backlog

Capture intentionally cut enhancements so they are not lost.

## Flutter-Specific Planning Heuristics

The skill should favor these planning heuristics:

- Prefer extending existing feature modules over creating new top-level architecture layers unless the current boundaries are clearly failing.
- Keep screens thin when possible; move orchestration out of large UI widgets when a feature would otherwise expand complexity sharply.
- Add a feature-specific adapter, controller, or repository when it reduces coupling to broad app services.
- Prefer typed state and explicit loading/error/empty handling over implicit UI assumptions.
- Preserve platform support expectations already present in the project unless the user explicitly narrows scope.
- Account for offline-first behavior when the app already has local-first or sync-related patterns.
- Treat accessibility and performance as MVP concerns when the feature directly affects interaction-heavy or high-frequency surfaces.

## Adapting to Service-First Codebases

The skill should include explicit advice for service-first repositories.

In these codebases, the default recommendation should be:

- reuse existing services where possible
- avoid introducing a new state-management framework just for one feature
- wrap broad services behind narrower feature-facing interfaces if the feature needs clearer boundaries
- split overly large screens only when the requested enhancement would otherwise make them harder to reason about or test
- borrow Flutter's view/view-model/repository/service separation as a planning lens, not as a forced renaming exercise

This avoids the common mistake of turning a feature plan into an unsolicited architecture migration.

## Non-Goals

The skill should not:

- force a full MVVM, Clean Architecture, or Bloc migration
- prescribe one state-management package by default
- generate implementation code as part of normal planning output
- recommend speculative abstractions without a clear feature-driven reason
- hide uncertainty when repository context is missing

## Example Success Criteria

The skill is successful if, after it triggers, the resulting plan:

- gives a smaller and clearer MVP than the original request
- fits the feature into the real codebase instead of describing a generic app
- exposes state, storage, sync, routing, and testing implications early
- suggests only justified refactors
- produces a task breakdown that an implementation pass can follow directly

## Implementation Direction

The eventual `SKILL.md` should:

- describe when to trigger in pushy, realistic terms
- instruct the model to inspect repo context first
- provide the output template above
- include planning heuristics for modern Flutter work
- include a dedicated section for adapting to existing service-heavy repos
- bias toward MVP scope cuts and incremental delivery

## Notes From Current Repo Review

The current `Steps-to-recovery-flutter` repo already reflects a mixed structure:

- feature folders exist under `lib/features`
- routing is centralized under `go_router`
- app-wide services are concentrated under `lib/core/services`
- some screens are already fairly large and blend UI with orchestration

That makes this repo a good reference example for the skill’s “adapt to an existing codebase first” guidance. The skill should be written to improve planning in exactly this kind of environment without assuming a greenfield rebuild.
