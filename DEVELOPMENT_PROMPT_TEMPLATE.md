# Development Session Request

```markdown
FOCUS AREA: [Describe what you want to work on]

CATEGORY: [New Feature | Feature Completion | Service Improvement | UI/UX Enhancement | Bug Fix | Testing | Performance | Refactoring | Documentation | Security]

MOTIVATION: [Why this matters - user need, technical debt, completeness, performance issue, bug, or enhancement]

SPECIFIC GOAL: 
[What you want to accomplish - be concrete and measurable]

CONSTRAINTS:
- Time available: [< 1 hour | 1-3 hours | Half day | Full day | Multi-day]
- Complexity tolerance: [Quick win | Moderate | Deep work | Architectural]
- Risk tolerance: [Low | Medium | High]
- Testing required: [Yes - add tests | Yes - verify existing | No - UI-only or docs]
- Dependencies: [List modules/services this touches]

SUCCESS CRITERIA:
1. [Measurable outcome 1]
2. [Measurable outcome 2]
3. [Measurable outcome 3]

TECHNICAL SCOPE:
- Files to modify: [List specific files or directories]
- Services involved: [PreferencesService | EncryptionService | DatabaseService | AppStateService | ConnectivityService | NotificationService | SyncService | AiService | LoggerService | AnalyticsService]
- UI changes: [Yes/No - describe if yes]
- Security/Privacy impact: [Describe if any]

OUTPUT NEEDED: [Implementation Plan | Code Generation | Code Review | Debugging Help | Architecture Guidance | Test Writing | Documentation | Refactoring Plan]
```

---

## Quick Example

```markdown
FOCUS AREA: Add biometric authentication lock for app access

CATEGORY: Security + Feature Enhancement

MOTIVATION: Users need quick, secure access to their recovery data with privacy protection

SPECIFIC GOAL: 
- Enable biometric auth (fingerprint/face) on app launch
- Add toggle in profile settings to enable/disable
- Show lock screen when app returns from background

CONSTRAINTS:
- Time available: 3-4 hours
- Complexity tolerance: Moderate
- Risk tolerance: Medium
- Testing required: Yes - add widget tests
- Dependencies: local_auth package, AppStateService

SUCCESS CRITERIA:
1. Biometric prompt shows on app launch when enabled
2. Settings toggle persists user preference
3. App locks when backgrounded for > 5 minutes

TECHNICAL SCOPE:
- Files to modify: lib/features/profile/, lib/core/services/app_state_service.dart
- Services involved: AppStateService, PreferencesService
- UI changes: Yes - lock screen overlay, settings toggle
- Security/Privacy impact: High - adds authentication layer

OUTPUT NEEDED: Implementation plan with code examples
```
