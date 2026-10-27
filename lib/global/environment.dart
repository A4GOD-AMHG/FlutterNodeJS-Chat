import 'dart:io';

class Environment {
  // Override with: flutter run --dart-define=SERVER_URL=https://my-server.com
  static const _serverUrl = String.fromEnvironment('SERVER_URL');

  static String get socketUrl => _serverUrl.isNotEmpty
      ? _serverUrl
      : Platform.isAndroid
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';

  static String get apiUrl => '$socketUrl/api';
}
