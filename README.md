# persist_http

[![pub](https://img.shields.io/pub/v/persist_http.svg)](https://pub.dev/packages/persist_http)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Github issues](https://img.shields.io/github/issues/JAYDARANIYA/persist_http)](https://github.com/JAYDARANIYA/persist_http/issues?q=is%3Aissue+is%3Aopen+)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/JAYDARANIYA/persist_http/pulls)

This library provides an efficient way to handle HTTP requests by reusing the same HTTP handshake. It's designed for Dart environments and supports all platforms except Flutter Web due to the use of dart:io.

## Installation
``` yaml
dependencies:
    persist_http: ^0.0.1-beta
```

## Example

```dart
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
```