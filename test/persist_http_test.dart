import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:persist_http/persist_http.dart';

void main() {
  test('Connection test', () async {
    final timeInstance = DateTime.now();
    final persistHttp = PresistHttp('google.com');
    await persistHttp.connect();
    debugPrint(
        'Connection time: ${DateTime.now().difference(timeInstance).inMilliseconds} ms');
    await persistHttp.close();
  });

  test('GET test', () async {
    var timeInstance = DateTime.now();
    final persistHttp = PresistHttp('randomuser.me');
    await persistHttp.connect();
    final _ = await persistHttp.get('/api/');
    debugPrint(
        'GET time: ${DateTime.now().difference(timeInstance).inMilliseconds} ms');

    // check for response in persist connection call
    for (var i = 0; i < 10; i++) {
      timeInstance = DateTime.now();
      final _ = await persistHttp.get('/api/');
      debugPrint(
          'GET $i time: ${DateTime.now().difference(timeInstance).inMilliseconds} ms');
    }

    await persistHttp.close();
  });
}
