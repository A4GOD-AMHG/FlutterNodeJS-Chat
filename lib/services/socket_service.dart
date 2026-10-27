// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:chat/global/environment.dart';
import 'package:chat/services/auth_service.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket? get socket => _socket;

  void emit(String event, dynamic data) => _socket?.emit(event, data);

  Future<void> connect() async {
    final token = await AuthService.getToken();

    // Never keep two sockets alive (e.g. logout + login again).
    _socket?.dispose();
    _serverStatus = ServerStatus.Connecting;

    _socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {'x-token': token}
    });

    _socket!.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _serverStatus = ServerStatus.Offline;
    notifyListeners();
  }
}
