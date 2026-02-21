# Steps to Recovery (Flutter Rebuild)

Fresh rebuild of the app using Flutter + Dart.

## Stack
- Flutter 3.41.x
- Dart 3.11.x
- Material 3 + `go_router`
- Local persistence (`shared_preferences`)
- Local notifications scaffold (`flutter_local_notifications`)
- Remote sync scaffold (`http`)

## Included
- Home dashboard with streak + next action
- Daily check-in (morning/evening)
- Journal page
- Progress page
- Support page
- Emergency contacts editor
- Reminder toggles + schedule hooks
- Offline-first with pending sync queue
- Sync-now action with retry/backoff

## Run
```bash
flutter pub get
flutter run
```

## Optional remote sync config
Pass backend values with dart-defines:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-api.example.com \
  --dart-define=API_AUTH_TOKEN=your_token_here
```

If `API_BASE_URL` is omitted, app runs fully offline/local.
