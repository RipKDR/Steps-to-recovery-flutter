import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/permissions_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  late List<MethodCall> permissionCalls;

  setUp(() {
    permissionCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          permissionCalls.add(call);
          if (call.method == 'openAppSettings') {
            return true;
          }
          if (call.method == 'checkPermissionStatus') {
            return 1;
          }
          if (call.method == 'requestPermissions') {
            return <int, int>{};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  test('openAppSettings delegates to permission_handler', () async {
    await PermissionsService().openAppSettings();

    expect(
      permissionCalls.where((call) => call.method == 'openAppSettings'),
      hasLength(1),
    );
  });
}
