import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bdmap_location_flutter_plugin/bdmap_location_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('bdmap_location_flutter_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LocationFlutterPlugin.platformVersion, '42');
  });
}
