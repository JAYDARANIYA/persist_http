import 'package:flutter/foundation.dart';
import 'package:persist_http/persist_http.dart';

void main() async {
  await connectionsCheck();
  await multiCallWithPersistConnection();
}

Future<void> connectionsCheck() async {
  var client = PresistHttp("example.com");
  await client.connect();
  await client.close();
}

Future<void> multiCallWithPersistConnection() async {
  final persistHttp = PresistHttp('randomuser.me');
  await persistHttp.connect();

  for (var i = 0; i < 10; i++) {
    final response = await persistHttp.get('/api');
    debugPrint(response);
  }

  await persistHttp.close();
}
