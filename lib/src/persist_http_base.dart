import 'package:persist_http/src/socket_manager.dart';

/// Base class for persist http
class PresistHttp {
  /// URL without query parameters or https:// or http://
  late String _url;

  /// Port to connect deault is 443 in case of http is 80
  int _port = 443;

  /// Socket manager
  final SocketManager _socketManager = SocketManager();

  /// Create new instance of persist http with url and late init when endpoint is called
  /// call [connect] to establish connection with server or when call endpoint it will be called
  /// [url] URL without query parameters or https:// or http://
  /// [port] Port to connect deault is 443 in case of http define 80
  PresistHttp(String url, [int port = 443]) {
    _url = url;
    _port = port;
  }

  /// Establish connection with server
  Future<void> connect() async {
    if (_socketManager.isConnected) {
      return;
    }
    await _socketManager.connect(_url, _port);
  }

  /// Close connection with server
  Future<void> close() async {
    if (!_socketManager.isConnected) {
      return;
    }
    await _socketManager.close();
  }

  /// Call GET endpoint with path or query parameters
  /// [path] Path or query parameters
  Future<String> get(String path) async {
    assert(_socketManager.isConnected, 'Connect to server first');

    final request = 'GET $path HTTP/1.1\r\n'
        'Host: $_url\r\n'
        'Connection: keep-alive\r\n'
        '\r\n';
    return await _socketManager.write(request);
  }
}
