import 'dart:convert';

import 'package:chat/global/environment.dart';
import 'package:chat/models/messages_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chat/models/user.dart';

class ChatService with ChangeNotifier {
  late User userFor;

  Future<Message?> sendMessage(String to, String text) async {
    try {
      final resp = await http.post(
        Uri.parse('${Environment.apiUrl}/messages'),
        body: json.encode({'to': to, 'message': text}),
        headers: await AuthService.authHeaders(),
      );
      if (resp.statusCode != 200) return null;
      return Message.fromJson(json.decode(resp.body));
    } catch (e) {
      debugPrint('sendMessage: $e');
      return null;
    }
  }

  Future<List<Message>> getChat(String userID, int limit) async {
    try {
      final resp = await http.get(
        Uri.parse('${Environment.apiUrl}/messages?from=$userID&limit=$limit'),
        headers: await AuthService.authHeaders(),
      );
      if (resp.statusCode != 200) return [];
      return messagesResponseFromJson(resp.body).messages;
    } catch (e) {
      debugPrint('getChat: $e');
      return [];
    }
  }

  Future<Message?> getLast(String userID) async {
    final messages = await getChat(userID, 1);
    return messages.isEmpty ? null : messages.first;
  }

  Future<bool> deleteMessage(String messageID) async {
    try {
      final resp = await http.delete(
        Uri.parse('${Environment.apiUrl}/messages/delete/$messageID'),
        headers: await AuthService.authHeaders(),
      );
      return resp.statusCode == 200;
    } catch (e) {
      debugPrint('deleteMessage: $e');
      return false;
    }
  }

  Future<bool> editMessage(String messageID, String text) async {
    try {
      final resp = await http.put(
        Uri.parse('${Environment.apiUrl}/messages/edit'),
        headers: await AuthService.authHeaders(),
        body: json.encode({'_id': messageID, 'message': text}),
      );
      return resp.statusCode == 200;
    } catch (e) {
      debugPrint('editMessage: $e');
      return false;
    }
  }
}
