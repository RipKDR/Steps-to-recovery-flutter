# Flutter Enhancement MVP Planner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and install a reusable Codex skill that turns Flutter enhancement requests into pragmatic MVP plans aligned with modern Flutter practices and adaptable to existing service-first codebases.

**Architecture:** Keep the canonical skill source inside this repo so it can be reviewed and versioned. Install the runnable copy into `C:\Users\H\.codex\skills\flutter-enhancement-mvp-planner` via a small sync script, then validate the skill in a fresh Codex session against smoke prompts derived from the approved spec.

**Tech Stack:** Markdown skill authoring, PowerShell install script, JSON eval prompts, Codex custom skills, repo context from `Steps-to-recovery-flutter`

---

## File Map

- Create: `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`
  Canonical, version-controlled skill definition.

- Create: `docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json`
  Smoke eval prompts covering service-first repos, oversized feature requests, and general Flutter enhancement planning.

- Create: `tool/install_flutter_enhancement_mvp_planner_skill.ps1`
  Copies the canonical skill into `C:\Users\H\.codex\skills\flutter-enhancement-mvp-planner`.

- Create at install time: `C:\Users\H\.codex\skills\flutter-enhancement-mvp-planner\SKILL.md`
  Installed runtime copy consumed by Codex after restart.

## Task 1: Scaffold the Skill Source and Installer

**Files:**
- Create: `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`
- Create: `docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json`
- Create: `tool/install_flutter_enhancement_mvp_planner_skill.ps1`

- [ ] **Step 1: Create the source directories**

Run:

```powershell
New-Item -ItemType Directory -Force -Path `
  'docs/superpowers/skills/flutter-enhancement-mvp-planner', `
  'docs/superpowers/skills/flutter-enhancement-mvp-planner/evals' | Out-Null
```

Expected: both directories exist under `docs/superpowers/skills/`.

- [ ] **Step 2: Create the installer script first**

Write `tool/install_flutter_enhancement_mvp_planner_skill.ps1`:

```powershell
param(
  [string]$Source = "docs/superpowers/skills/flutter-enhancement-mvp-planner",
  [string]$Destination = "$HOME/.codex/skills/flutter-enhancement-mvp-planner"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedSource = Join-Path $repoRoot $Source

if (-not (Test-Path $resolvedSource)) {
  throw "Skill source not found: $resolvedSource"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
Remove-Item -Recurse -Force $Destination -ErrorAction SilentlyContinue
Copy-Item -Recurse -Force $resolvedSource $Destination

Write-Host "Installed flutter-enhancement-mvp-planner to $Destination"
```

- [ ] **Step 3: Verify the installer script parses**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$tokens = $null; $errors = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path (Get-Location) 'tool/install_flutter_enhancement_mvp_planner_skill.ps1'), [ref]$tokens, [ref]$errors); if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_.Message }; exit 1 }"
```

Expected: no output and exit code `0`.

- [ ] **Step 4: Add the empty skill placeholder so install steps can run later**

Write `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`:

```md
---
name: flutter-enhancement-mvp-planner
description: Plan Flutter feature enhancements as pragmatic MVPs that fit the current codebase. Use when the user asks to scope a Flutter feature, break down an MVP, fit an enhancement into an existing Flutter app, or decide what minimal refactors are worth doing before implementation.
---

# Flutter Enhancement MVP Planner
```

- [ ] **Step 5: Commit the scaffold**

Run:

```powershell
git add -- docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md tool/install_flutter_enhancement_mvp_planner_skill.ps1
git commit -m "feat: scaffold flutter enhancement planner skill"
```

Expected: one commit containing the new skill skeleton and installer.

## Task 2: Author the Trigger Contract and Planning Workflow

**Files:**
- Modify: `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`

- [ ] **Step 1: Expand the frontmatter description so the skill triggers on real planning requests**

Replace the initial description with language that covers:

- Flutter feature planning
- MVP scoping
- enhancement breakdowns
- architecture-fit questions
- existing codebase adaptation

Use this frontmatter:

```md
---
name: flutter-enhancement-mvp-planner
description: Plan Flutter feature enhancements as pragmatic MVPs that fit the current codebase and modern Flutter practices. Use whenever the user asks to plan a Flutter feature, shape an MVP, break an enhancement into implementation slices, fit a feature into an existing Flutter app, or decide which minimal refactors are worth doing before coding.
---
```

- [ ] **Step 2: Add the overview and use-cases**

Add these sections:

```md
## Overview
Turn Flutter enhancement requests into implementation-ready MVP plans. Inspect the repo first, reduce scope to the smallest credible release, and map the change onto the app's real folders, routes, services, models, widgets, and tests.

## When to Use
- Planning a new Flutter feature before coding
- Tightening an over-scoped enhancement into a phase-1 MVP
- Figuring out where a feature belongs in an existing Flutter codebase
- Deciding whether a refactor is necessary before implementing a Flutter change
```

- [ ] **Step 3: Add the required workflow**

Add a workflow section that instructs the skill to:

```md
## Workflow
1. Read the current repo structure before proposing changes.
2. Restate the feature goal and identify the user/problem being served.
3. Cut the request down to the smallest credible MVP.
4. Fit the work into the existing architecture first.
5. Recommend only the refactors that materially reduce implementation risk.
6. Produce an implementation-ready plan in small vertical slices.
7. If the request is too broad, split it into phase 1 and later phases.
```

- [ ] **Step 4: Add the chat-first planning style guardrail**

Add:

```md
## Planning Style
- Default to a complete planning response in chat.
- Only suggest or generate a file when the user explicitly asks for one.
- Keep the plan pragmatic, repo-aware, and specific enough to implement without drifting into greenfield advice.
```

- [ ] **Step 5: Verify the draft contains the core sections**

Run:

```powershell
rg "^## (Overview|When to Use|Workflow|Planning Style)$" `
  docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md
```

Expected:

```text
## Overview
## When to Use
## Workflow
## Planning Style
```

- [ ] **Step 6: Commit the planning workflow draft**

Run:

```powershell
git add -- docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md
git commit -m "feat: add planner trigger contract and workflow"
```

Expected: one commit that introduces the actual planning behavior.

## Task 3: Add the Output Contract and Flutter-Specific Heuristics

**Files:**
- Modify: `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`

- [ ] **Step 1: Add the output template**

Append this exact structure:

```md
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
```

- [ ] **Step 2: Add Flutter planning heuristics**

Append guidance like:

```md
## Flutter Heuristics
- Prefer extending existing feature modules before creating new top-level architecture layers unless the current boundaries are clearly failing.
- Keep screens thin when possible; move orchestration out of large UI widgets when a feature would otherwise expand complexity sharply.
- Add a feature-specific adapter, controller, or repository when it reduces coupling to broad app services.
- Prefer typed state and explicit loading, empty, and error handling over implicit UI assumptions.
- Preserve platform support expectations already present in the project unless the user explicitly narrows scope.
- Account for offline-first behavior when the app already has local-first or sync-related patterns.
- Treat accessibility and performance as MVP concerns when the feature directly affects interaction-heavy or high-frequency surfaces.
```

- [ ] **Step 3: Add service-first adaptation guidance**

Append:

```md
## Adapting to Service-First Codebases
- Reuse existing services where possible.
- Avoid introducing a new state-management framework just for one feature.
- Wrap broad services behind narrower feature-facing interfaces if the feature needs clearer boundaries.
- Split overly large screens only when the requested enhancement would otherwise make them harder to reason about or test.
- Borrow Flutter's view/view-model/repository/service separation as a planning lens, not as a forced renaming exercise.
- Reuse existing routing, persistence, notification, and service patterns before proposing new layers.
```

- [ ] **Step 4: Add non-goals and anti-patterns**

Append:

```md
## Avoid
- Full architecture migrations unless the user explicitly asks for one
- Speculative abstractions
- Generic plans that ignore the actual repo
- Output that skips tests, accessibility, privacy, or performance when they are relevant
- Recommending Riverpod, Bloc, Provider, or another state-management package unless the repo already uses it or the user explicitly asks for it
```

- [ ] **Step 5: Verify the critical headings are present**

Run:

```powershell
rg "^## (Output|Flutter Heuristics|Adapting to Service-First Codebases|Avoid)$" `
  docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md
```

Expected:

```text
## Output
## Flutter Heuristics
## Adapting to Service-First Codebases
## Avoid
```

- [ ] **Step 6: Commit the completed skill draft**

Run:

```powershell
git add -- docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md
git commit -m "feat: complete flutter planner guidance"
```

Expected: one commit containing the finished MVP version of the skill text.

## Task 4: Add Smoke Evals Before Behavioral Validation

**Files:**
- Create: `docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json`

- [ ] **Step 1: Write three eval prompts that cover the hardest planning cases**

Create `docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json`:

```json
{
  "skill_name": "flutter-enhancement-mvp-planner",
  "evals": [
    {
      "id": 1,
      "prompt": "Plan an MVP for adding sponsor check-in reminders to an existing Flutter recovery app that already has feature folders, go_router, local notifications, and shared services. Keep it small and tell me what to defer.",
      "expected_output": "A chat-first MVP plan with the sections Feature summary, MVP scope, Existing-code fit, UI and interaction plan, State and data flow, Platform and cross-cutting impact, Refactors worth doing now, Test plan, Execution slices, and Deferred backlog. MVP scope should separate in-scope, out-of-scope, and deferred work. Existing-code fit should reuse current routes and services. Platform and cross-cutting impact should cover notifications, permissions, and persistence touchpoints. The plan must avoid forcing a new state-management package.",
      "files": [
        "lib/features/sponsor/screens/sponsor_screen.dart",
        "lib/core/services/notification_service.dart",
        "lib/navigation/app_router.dart"
      ]
    },
    {
      "id": 2,
      "prompt": "I want to add habit tracking, rewards, social sharing, badges, streak rescue, Apple Watch sync, and AI coaching to my Flutter app. Break this into a phase-1 MVP and later phases.",
      "expected_output": "A chat-first plan that explicitly separates phase 1 from later phases, identifies the smallest shippable release, and uses the MVP scope plus Deferred backlog sections to show what was cut. The response should avoid architecture churn and keep phase 1 materially smaller than the original request.",
      "files": [
        "lib/features/home/screens/home_screen.dart"
      ]
    },
    {
      "id": 3,
      "prompt": "Figure out how a new crisis support flow should fit into my Flutter app. I need screens, state flow, test coverage, accessibility, and any refactors that are actually worth doing now.",
      "expected_output": "A structured chat-first plan with UI and interaction states including loading, empty, error, and success, explicit state and data flow, a test plan using unit, widget, and targeted integration coverage, accessibility guidance, platform and cross-cutting notes, and only minimal refactors with short reasons or an explicit statement that none are needed.",
      "files": [
        "lib/features/crisis/screens/emergency_screen.dart",
        "lib/navigation/app_router.dart"
      ]
    }
  ]
}
```

- [ ] **Step 2: Validate the JSON**

Run:

```powershell
python -m json.tool docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json > $null
```

Expected: no output and exit code `0`.

- [ ] **Step 3: Spot-check the eval file contents**

Run:

```powershell
Get-Content docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json
```

Expected: exactly three eval entries with realistic Flutter planning prompts.

- [ ] **Step 4: Commit the eval set**

Run:

```powershell
git add -- docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json
git commit -m "test: add smoke evals for flutter planner skill"
```

Expected: one commit containing the initial validation prompts.

## Task 5: Install the Skill Locally and Run a Manual Validation Pass

**Files:**
- Modify if needed: `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`
- Runtime install target: `C:\Users\H\.codex\skills\flutter-enhancement-mvp-planner\SKILL.md`

- [ ] **Step 1: Install the repo-tracked skill into the live Codex skills directory**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File `
  .\tool\install_flutter_enhancement_mvp_planner_skill.ps1
```

Expected:

```text
Installed flutter-enhancement-mvp-planner to C:\Users\<you>\.codex\skills\flutter-enhancement-mvp-planner
```

- [ ] **Step 2: Verify the installed files exist**

Run:

```powershell
Get-ChildItem -Recurse "$HOME/.codex/skills/flutter-enhancement-mvp-planner" | Select-Object FullName
```

Expected: the installed folder contains `SKILL.md` and `evals/evals.json`.

- [ ] **Step 3: Restart Codex before behavioral testing**

Action:

```text
Close and reopen Codex so the new skill metadata is loaded.
```

Expected: a fresh session can discover `flutter-enhancement-mvp-planner`.

- [ ] **Step 4: Run smoke prompt 1 in a fresh session**

Use this exact prompt:

```text
Plan an MVP for adding sponsor check-in reminders to an existing Flutter recovery app that already has feature folders, go_router, local notifications, and shared services. Keep it small and tell me what to defer.
```

Expected:

- output includes `Feature summary`, `MVP scope`, `Existing-code fit`, `Platform and cross-cutting impact`, `Test plan`, and `Deferred backlog`
- `MVP scope` separates in-scope, out-of-scope, and deferred work
- plan reuses existing services and routes
- plan covers notification, permission, and persistence touchpoints
- plan does not force Riverpod, Bloc, or another new state-management stack

- [ ] **Step 5: Run smoke prompt 2 in a fresh session**

Use this exact prompt:

```text
I want to add habit tracking, rewards, social sharing, badges, streak rescue, Apple Watch sync, and AI coaching to my Flutter app. Break this into a phase-1 MVP and later phases.
```

Expected:

- output clearly separates phase 1 from later phases
- phase 1 is materially smaller than the original request
- deferred items are explicit, not implied
- response stays chat-first and avoids unnecessary architecture churn

- [ ] **Step 6: Run smoke prompt 3 in a fresh session**

Use this exact prompt:

```text
Figure out how a new crisis support flow should fit into my Flutter app. I need screens, state flow, test coverage, accessibility, and any refactors that are actually worth doing now.
```

Expected:

- output includes loading, empty, error, and success states, explicit data flow, test mix, accessibility, cross-cutting impact, and minimal refactors with reasons
- plan is specific to the repo context if run inside a repo
- refactors are justified, not speculative

- [ ] **Step 7: If any smoke prompt fails, refine the skill once before expanding scope**

Action:

```text
If the skill misses sections, over-scopes the MVP, ignores repo fit, or recommends architecture churn, edit the repo-tracked SKILL.md, reinstall with the PowerShell script, restart Codex, and rerun the failed prompt only.
```

Expected: one focused refinement pass, not an open-ended rewrite loop.

- [ ] **Step 8: Commit the validated MVP**

Run:

```powershell
git add -- docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json tool/install_flutter_enhancement_mvp_planner_skill.ps1
git commit -m "feat: add flutter enhancement mvp planner skill"
```

Expected: one final commit containing the validated skill source, installer, and smoke evals.

## Task 6: Optional Post-MVP Hardening

**Files:**
- Modify if needed: `docs/superpowers/skills/flutter-enhancement-mvp-planner/SKILL.md`
- Modify if needed: `docs/superpowers/skills/flutter-enhancement-mvp-planner/evals/evals.json`

- [ ] **Step 1: If trigger quality is weak, run a second iteration using `@skill-creator`**

Action:

```text
Use @skill-creator only after the MVP smoke prompts work. Add near-miss prompts, compare behavior with and without the skill, and refine the description if the skill under-triggers or over-triggers.
```

Expected: better triggering without changing the core planning contract.

- [ ] **Step 2: If SKILL.md becomes too long, split reference material instead of bloating it**

Action:

```text
Move large examples or checklists into docs/superpowers/skills/flutter-enhancement-mvp-planner/references/ and keep SKILL.md focused on trigger and workflow guidance.
```

Expected: `SKILL.md` remains readable and concise.
