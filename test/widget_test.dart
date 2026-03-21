
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/navigation/shell_screen.dart';
import 'package:steps_recovery_flutter/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StepsToRecoveryApp());
    await tester.pumpAndSettle();
    expect(find.byType(ShellScreen), findsOneWidget);
  });
}
