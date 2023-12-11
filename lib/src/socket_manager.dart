import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class SocketManager {
  /// If 443 then SecureSocket or Socket
  late dynamic _socket;

  final List<Completer<String>> _requestsStack = [];

  bool isConnected = false;

  Future<void> connect(String url, int port) async {
    if (port != 80 && port != 44) {
      await _connectSecureSocket(url, port);
    } else {
      await _connectSocket(url, port);
    }
    isConnected = true;
    debugPrint('Connected to: '
        '${_socket.remoteAddress.address}:${_socket.remotePort}');
    // start listening to the socket
    listenForMessages();
  }

  Future<void> _connectSocket(String url, int port) async {
    _socket = await Socket.connect(url, port);
  }

  Future<void> _connectSecureSocket(String url, int port) async {
    _socket = await SecureSocket.connect(url, port);
  }

  void listenForMessages() {
    var buffer = StringBuffer();
    var isHeaderParsed = false;
    var contentLength = 0;
    var receivedLength = 0;
    var isChunked = false;
    var chunkSize = 0;
    var chunkBuffer = StringBuffer();

    _socket.listen((List<int> event) {
      buffer.write(String.fromCharCodes(event));

      if (!isHeaderParsed) {
        if (buffer.toString().contains('\r\n\r\n')) {
          isHeaderParsed = true;
          var headers = buffer.toString().split('\r\n\r\n')[0];
          if (headers.contains('Content-Length:')) {
            var matches = RegExp(r'Content-Length: (\d+)').firstMatch(headers);
            if (matches != null && matches.groupCount >= 1) {
              contentLength = int.parse(matches.group(1)!);
            }
          }
          if (headers.contains('Transfer-Encoding: chunked')) {
            isChunked = true;
          }
          buffer = StringBuffer(buffer.toString().split('\r\n\r\n')[1]);
        }
      }

      if (isHeaderParsed) {
        if (isChunked) {
          while (buffer.isNotEmpty) {
            if (chunkSize == 0) {
              var indexOfCrlf = buffer.toString().indexOf('\r\n');
              if (indexOfCrlf == -1) break;
              var sizeString = buffer.toString().substring(0, indexOfCrlf);
              chunkSize = int.parse(sizeString, radix: 16);
              buffer =
                  StringBuffer(buffer.toString().substring(indexOfCrlf + 2));
              if (chunkSize == 0) {
                if (_requestsStack.isNotEmpty) {
                  var completer = _requestsStack.removeAt(0);
                  completer.complete(chunkBuffer.toString());
                  buffer.clear();
                  chunkBuffer.clear();
                  isHeaderParsed = false;
                }
                break;
              }
            } else {
              if (buffer.length < chunkSize + 2) break;
              chunkBuffer.write(buffer.toString().substring(0, chunkSize));
              buffer = StringBuffer(buffer.toString().substring(chunkSize + 2));
              chunkSize = 0;
            }
          }
        } else if (contentLength > 0) {
          receivedLength += event.length;
          if (receivedLength >= contentLength) {
            var response = buffer.toString();
            if (_requestsStack.isNotEmpty) {
              var completer = _requestsStack.removeAt(0);
              completer.complete(response);
              buffer.clear();
              isHeaderParsed = false;
              receivedLength = 0;
            }
          }
        }
      }
    }, onError: (error) {
      debugPrint('Error: $error');
      close();
    }, onDone: () {
      debugPrint('Connection closed');
      close();
    });
  }

  Future<void> close() async {
    await _socket.close();
  }

  Future<String> write(String request) async {
    _socket.write(request);
    Completer<String> completer = Completer();
    _requestsStack.add(completer);
    return await completer.future;
  }
}
