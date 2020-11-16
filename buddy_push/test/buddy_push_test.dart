import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_push/buddy_push.dart';

void main() {
  const MethodChannel channel = MethodChannel('buddy_push');

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
    expect(await BuddyPush.currentPushDriver, '42');
  });
}
