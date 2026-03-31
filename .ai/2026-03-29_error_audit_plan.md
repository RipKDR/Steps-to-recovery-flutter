# Steps to Recovery Error Audit Plan

## Scope
- Treat the March 27 analyze/test logs as historical only. They conflict with later same-day passing logs and should not drive fixes by themselves.
- Fix the verified current issues first, then rerun verification in the current dirty workspace to discover anything else that is actually broken now.

## Recommended Fix Order
1. Stabilize Firebase bootstrap and web config.
2. Remove web-incompatible file IO from milestone sharing.
3. Fix the `PermissionsService.openAppSettings()` recursion bug.
4. Fix cross-account recovery metadata leakage in `AppStateService`.
5. Run targeted tests, then repo-wide verification.

## Changes

### 1. Firebase bootstrap
- Modify `lib/main.dart`.
- Modify `lib/firebase_options.dart`.
- Replace unconditional `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` with a guarded startup path that only initializes Firebase when the current platform has generated options.
- Add a non-throwing accessor in `lib/firebase_options.dart` such as `maybeCurrentPlatform` so desktop startup can skip Firebase cleanly instead of relying on `UnsupportedError`.
- Correct the web `authDomain` to `flutter-step-build.firebaseapp.com`.

Reasoning:
- The app supports Windows builds, but the generated Firebase options currently throw on Windows/Linux/macOS.
- The current web `authDomain` is malformed and will break Firebase auth redirects if web auth is ever used.
- The practical fix is to skip Firebase on unsupported desktop targets for now, not to broaden this task into full FlutterFire desktop enablement.

### 2. Web-safe milestone sharing
- Modify `lib/features/milestone/widgets/milestone_share_card.dart`.
- Verify existing callers in `lib/features/home/screens/home_screen.dart` and `lib/features/milestone/screens/milestone_celebration_screen.dart` still work without further API changes.
- Remove `dart:io` and `path_provider`.
- Change `MilestoneShareCard.capture()` to produce an in-memory PNG and return `XFile.fromData(...)` instead of writing a temp file.

Reasoning:
- `MilestoneShareCard` is imported from shared UI, so its `dart:io` import is a web compile blocker even if capture only runs on mobile.
- Using `XFile.fromData` is the simplest cross-platform fix and avoids adding conditional imports unless needed later.

### 3. Permission settings recursion
- Modify `lib/core/services/permissions_service.dart`.
- Alias the `permission_handler` import and explicitly call the package-level `openAppSettings()` function.

Reasoning:
- The current method recursively calls itself and will never reach the plugin.

### 4. Multi-account data isolation
- Modify `lib/core/services/app_state_service.dart`.
- In `signOut()`, also remove persisted `_keySobrietyDate` and `_keyProgramType`.
- In `signIn()`, stop defaulting to `_sobrietyDate` / `_programType` from prior session memory.
- Let the active user profile rehydrate those values after `DatabaseService().setActiveUser(...)`.

Reasoning:
- The new local multi-account flow can currently leak sobriety date and program type from one account into the next account session.
- This is a privacy and correctness bug, and it is narrow enough to fix without redesigning the auth service.

## Tests To Add Or Update
- Modify `test/auth_flow_test.dart`.
  - Add a regression test that `signOut()` clears persisted sobriety/program keys.
  - Add a regression test that signing into a second account does not inherit the first account's sobriety date or program type.
- Add `test/firebase_options_test.dart`.
  - Assert the corrected web `authDomain`.
  - Assert the new Firebase accessor is safe on unsupported desktop targets.
- Add `test/permissions_service_test.dart`.
  - Mock the permission-handler channel and verify `openAppSettings()` completes through the plugin path.
- Optionally add `test/milestone_share_card_test.dart` only if `XFile.fromData` capture can be tested reliably without brittle rendering setup.

## Verification
1. `.\tool\flutterw.ps1 test test/firebase_options_test.dart`
2. `.\tool\flutterw.ps1 test test/permissions_service_test.dart`
3. `.\tool\flutterw.ps1 test test/auth_flow_test.dart`
4. `.\tool\flutterw.ps1 test test/home_milestone_share_test.dart`
5. `.\tool\flutterw.ps1 test test/milestone_celebration_screen_test.dart`
6. `.\tool\flutterw.ps1 analyze`
7. `.\tool\flutterw.ps1 build web`
8. `.\tool\flutterw.ps1 test`
9. If desktop tooling is available: `.\tool\flutterw.ps1 build windows`

## Guardrails During Execution
- Do not revert unrelated user changes in the dirty workspace.
- Keep Firebase desktop support out of scope unless verification proves it is required for the user's current target platforms.
- If repo-wide verification surfaces new failures after these fixes, treat them as current-state issues and triage them separately from the stale March 27 logs.
