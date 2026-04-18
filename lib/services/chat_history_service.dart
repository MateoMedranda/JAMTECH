import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';
import 'api_service.dart';

class ChatHistoryService {
  Future<List<ChatHistory>> obtenerHistorial(String userId) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/medical-bot/conversations/$userId',
      );

      final headers = {'Content-Type': 'application/json'};
      if (ApiService.authToken != null) {
        headers['Authorization'] = 'Bearer ${ApiService.authToken}';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Si es una lista, convertirla
        List<dynamic> conversations = [];
        if (data is List) {
          conversations = data;
        } else if (data is Map && data['conversations'] != null) {
          conversations = data['conversations'];
        }

        final historial = conversations.map((conv) {
          return ChatHistory(
            conversationId: conv['session_id'] ?? conv['_id'] ?? '',
            diagnosis: conv['title'] ?? conv['diagnosis'] ?? 'Conversación',
            date: conv['date'] ?? DateTime.now().toString(),
            messageCount: conv['message_count'] ?? 0,
          );
        }).toList();

        return historial;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> eliminarConversacion(String conversationId) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/medical-bot/conversations/$conversationId',
      );

      final headers = {'Content-Type': 'application/json'};
      if (ApiService.authToken != null) {
        headers['Authorization'] = 'Bearer ${ApiService.authToken}';
      }

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class ChatHistory {
  final String conversationId;
  final String diagnosis;
  final String date;
  final int messageCount;

  ChatHistory({
    required this.conversationId,
    required this.diagnosis,
    required this.date,
    required this.messageCount,
  });

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}
