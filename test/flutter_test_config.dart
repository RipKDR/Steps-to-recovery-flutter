import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// This file runs before all tests in the test suite.
// Disabling runtime font fetching prevents network calls during tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
