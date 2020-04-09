import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wf_chat/wf_chat.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugin.newstyle.flutter.io/wf_network_m');
  WFChat _chat = WFChat();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('clientId', () async {
    expect(await _chat.clientId, '42');
  });
}
