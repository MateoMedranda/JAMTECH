import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/message_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../providers/message_provider.dart';
import '../../../providers/photo_provider.dart';
import '../../../models/message_model.dart';
import '../../../widgets/bubble_chat.dart';
import '../../../widgets/bot_response.dart';
import '../../../widgets/typing_indicator.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final MessageController _messageController;
  late String sessionId;
  late String userId;

  @override
  void initState() {
    super.initState();

    _messageController = MessageController(context.read<MessageProvider>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtener sessionId del PhotoProvider
      final photoProvider = context.read<PhotoProvider>();
      final authController = context.read<AuthController>();

      sessionId = photoProvider.conversationId ?? 'default_session';
      userId = authController.currentUser?.email ?? 'unknown';

      context.read<MessageProvider>().clearMessages();

      _messageController.obtenerMensajes(sessionId: sessionId);

      // Verificar si hay un análisis nuevo y no se ha enviado el mensaje inicial
      if (photoProvider.diagnosis != null &&
          !photoProvider.initialMessageSent) {
        // Esperar a que se carguen los mensajes históricos
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && context.read<PhotoProvider>().diagnosis != null) {
            _enviarMensajeInicial(context.read<PhotoProvider>());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _enviarMensajeInicial(PhotoProvider photoProvider) {
    final diagnosis = photoProvider.diagnosis ?? 'Análisis completado';
    final confidence = photoProvider.confidence ?? 0.0;

    // Crear mensaje inicial
    final initialMessage =
        '📋 He detectado: $diagnosis\n'
        '✅ Confianza: ${(confidence * 100).toStringAsFixed(2)}%\n\n'
        '¿Cuáles son tus síntomas actuales?';

    // Agregar mensaje del usuario
    context.read<MessageProvider>().addMessage(
      Message(type: 'user', content: initialMessage),
    );

    // Marcar que ya se envió el mensaje inicial
    photoProvider.setInitialMessageSent(true);

    // Enviar al backend y obtener respuesta
    _messageController.enviarMensaje(
      context: context,
      message: initialMessage,
      sessionId: sessionId,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();

    _scrollToBottom();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemCount:
                provider.messages.length + 1 + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Image.asset(
                      'assets/images/bot_logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.auto_awesome,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              if (provider.isLoading && index == provider.messages.length + 1) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: TypingIndicator(),
                );
              }

              final message = provider.messages[index - 1];

              if (message.type == 'ai') {
                return BotResponse(text: message.content);
              } else {
                return Align(
                  alignment: Alignment.centerRight,
                  child: BubbleChat(
                    text: message.content,
                    color: AppColors.primaryDark,
                    textColor: AppColors.white,
                  ),
                );
              }
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 8, color: Colors.black.withAlpha(13)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: AppColors.primary,
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<MessageProvider>().addMessage(
      Message(type: 'user', content: text),
    );

    _textController.clear();

    _messageController.enviarMensaje(
      context: context,
      message: text,
      sessionId: sessionId,
      userId: userId,
    );
  }
}
