import 'package:flutter/material.dart';
import 'chatbot_view.dart';

/// ChatView antiguo — redirigido al nuevo ChatbotView.
/// Mantenido para compatibilidad de cualquier referencia existente.
class ChatView extends StatelessWidget {
  final String sessionId;
  final String userId;

  const ChatView({super.key, required this.sessionId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const ChatbotView();
  }
}
