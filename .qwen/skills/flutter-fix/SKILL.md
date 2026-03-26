# Flutter Fix Skill

## Purpose
Systematically diagnose and fix Flutter compilation issues on Windows.

## Steps

### 1. Run Flutter Doctor
```bash
.\tool\flutterw.ps1 doctor -v
```
Check for:
- Missing Android SDK components
- Unaccepted Android licenses
- Missing Visual Studio C++ workload (for Windows builds)
- Device/emulator availability

### 2. Run Flutter Pub Get
```bash
.\tool\flutterw.ps1 pub get
```
Ensures all dependencies are resolved. Check for:
- Version conflicts
- Missing packages
- Corrupted pub cache

### 3. Run Flutter Build APK (Debug)
```bash
.\tool\flutterw.ps1 build apk --debug
```
Captures all compilation errors early. Watch for:
- Type errors
- Missing imports
- Deprecated API usage
- Platform-specific issues

### 4. Fix Compilation Errors Iteratively
For each error:
1. Read the error message carefully
2. Navigate to the file and line number
3. Apply the minimal fix
4. Re-run `.\tool\flutterw.ps1 build apk --debug`
5. Repeat until build succeeds

Common fixes:
- Add missing imports
- Fix type mismatches
- Update deprecated APIs
- Resolve null safety issues
- Check platform channel implementations

## Completion Criteria
- `flutter doctor` shows no critical issues
- `flutter pub get` completes successfully
- `flutter build apk --debug` completes with no errors
