Place the following icon files in this directory:

1. `app_icon.png` — 1024x1024 main app icon (recovery-themed, dark bg with amber accent)
2. `app_icon_foreground.png` — 1024x1024 adaptive icon foreground (Android, transparent bg)
3. `splash_logo.png` — 512x512 splash screen logo (centered on #0A0A0A background)

Then run:
```
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```
