// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// NOTE: This is a stub. Run `flutterfire configure` to generate real options.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase not configured for Linux.');
      default:
        throw UnsupportedError('Unsupported platform for Firebase.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'STUB',
    appId: 'STUB',
    messagingSenderId: 'STUB',
    projectId: 'STUB',
    authDomain: 'STUB',
    storageBucket: 'STUB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'STUB',
    appId: 'STUB',
    messagingSenderId: 'STUB',
    projectId: 'STUB',
    storageBucket: 'STUB',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'STUB',
    appId: 'STUB',
    messagingSenderId: 'STUB',
    projectId: 'STUB',
    storageBucket: 'STUB',
    iosBundleId: 'STUB',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'STUB',
    appId: 'STUB',
    messagingSenderId: 'STUB',
    projectId: 'STUB',
    storageBucket: 'STUB',
    iosBundleId: 'STUB',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'STUB',
    appId: 'STUB',
    messagingSenderId: 'STUB',
    projectId: 'STUB',
    authDomain: 'STUB',
    storageBucket: 'STUB',
  );
}
