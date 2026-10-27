import 'dart:convert';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  User? user;
  bool _authenticating = false;

  static const _storage = FlutterSecureStorage();

  bool get authenticating => _authenticating;

  set authenticating(bool value) {
    _authenticating = value;
    notifyListeners();
  }

  static Future<String?> getToken() => _storage.read(key: 'token');

  static Future<void> deleteToken() => _storage.delete(key: 'token');

  /// JSON headers including the stored session token.
  static Future<Map<String, String>> authHeaders() async => {
        'Content-Type': 'application/json',
        'x-token': await getToken() ?? '',
      };

  Future<bool> login(String email, String password) async {
    return await _authenticate('login', {
          'email': email,
          'password': password,
        }) ==
        null;
  }

  /// Returns null on success or an error message to show the user.
  Future<String?> register(String name, String email, String password) {
    return _authenticate('login/new', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<String?> _authenticate(String path, Map<String, String> data) async {
    authenticating = true;
    try {
      final resp = await http.post(
        Uri.parse('${Environment.apiUrl}/$path'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        final loginResponse = loginResponseFromJson(resp.body);
        user = loginResponse.user;
        await _saveToken(loginResponse.token);
        return null;
      }
      return _errorMessage(resp.body);
    } catch (_) {
      return 'No se pudo conectar con el servidor';
    } finally {
      authenticating = false;
    }
  }

  /// Server errors come as { msg } or as express-validator { errors: { field: { msg } } }.
  static String _errorMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json['msg'] is String) return json['msg'];
      final errors = json['errors'];
      if (errors is Map && errors.isNotEmpty) {
        return errors.values.first['msg'] ?? 'Datos no válidos';
      }
    } catch (_) {}
    return 'Ocurrió un error inesperado';
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final resp = await http.get(
        Uri.parse('${Environment.apiUrl}/login/renew'),
        headers: {'Content-Type': 'application/json', 'x-token': token},
      );

      if (resp.statusCode == 200) {
        final loginResponse = loginResponseFromJson(resp.body);
        user = loginResponse.user;
        await _saveToken(loginResponse.token);
        return true;
      }
    } catch (_) {}

    await logout();
    return false;
  }

  Future<void> _saveToken(String token) =>
      _storage.write(key: 'token', value: token);

  Future<void> logout() async {
    user = null;
    await deleteToken();
  }
}
