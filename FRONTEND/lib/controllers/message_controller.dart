import 'package:flutter/material.dart';
import '../providers/message_provider.dart';
import '../services/message_service.dart';
import '../models/message_model.dart';

class MessageController {
  final MessageProvider provider;
  final MessageService service = MessageService();

  MessageController(this.provider);

  Future<void> enviarMensaje({
    required BuildContext context,
    required String message,
    required String sessionId,
    required String userId,
  }) async {
    if (message == '') return;

    provider.setLoading(true);

    try {
      final Message botResponse = await service.sendMessage(
        userId: userId,
        sessionId: sessionId,
        message: message,
      );

      if (botResponse.content != '') {
        provider.addMessage(botResponse);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al obtener respuesta del bot')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      provider.setLoading(false);
    }
  }

  Future<void> obtenerMensajes({required String sessionId}) async {
    if (sessionId == '') return;

    final List<Message> messages = await service.getChatMessages(
      sessionId: sessionId,
    );

    if (messages.isNotEmpty) {
      // Intentar obtener la imagen asociada a la sesión (del registro clínico)
      print('DEBUG: Attempting to fetch image for sessionId: $sessionId');
      final imageUrl = await service.getSessionImage(sessionId);
      if (imageUrl != null) {
        print('DEBUG: Attaching image URL to first message: $imageUrl');
        // Asignar la imagen al primer mensaje (asumiendo que es el del usuario)
        // O al primer mensaje de la lista si no hay distinción clara
        final firstMessage = messages[0];
        // Crear una copia del mensaje con la URL de la imagen (Message es inmutable pero podemos recrearlo)
        final newMessage = Message(
          type: firstMessage.type,
          content: firstMessage.content,
          imageUrl: imageUrl,
        );
        messages[0] = newMessage;
      } else {
        print('DEBUG: No image URL found for sessionId: $sessionId');
      }

      provider.addMessages(messages);
    }
  }
}
