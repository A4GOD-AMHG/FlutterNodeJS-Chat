import 'package:chat/global/environment.dart';
import 'package:chat/models/users_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chat/models/user.dart';

class UsersService {
  Future<List<User>> getUsers() async {
    try {
      final resp = await http.get(
        Uri.parse('${Environment.apiUrl}/users'),
        headers: await AuthService.authHeaders(),
      );
      if (resp.statusCode != 200) return [];
      return usersResponseFromJson(resp.body).users;
    } catch (e) {
      debugPrint('getUsers: $e');
      return [];
    }
  }
}
