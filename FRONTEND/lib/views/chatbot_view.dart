import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/constants.dart';
import 'package:uuid/uuid.dart';
import '../services/message_service.dart';
import '../models/conversation_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/chart_data_parser.dart';
import '../widgets/chat_chart_widget.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  final MessageService _messageService = MessageService();
  String _sessionId = const Uuid().v4();
  final String _userId = "1";
  List<Conversation> _conversations = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentlyPlayingId;

  // Categorías de sugerencias dinámicas
  final Map<String, List<String>> _suggestionCategories = {
    'ventas': [
      '¿Cuánto vendí esta semana?',
      '¿Cómo me fue este mes comparado con el mes pasado?',
      '¿Cuánto llevo vendido este año?',
      '¿Cuál fue mi mejor mes del año?',
      '¿Voy a llegar a \$5,000 este mes?',
      'Muéstrame una gráfica de mis ventas',
    ],
    'tiempo': [
      '¿Cuál es mi mejor día de la semana?',
      '¿Cuál es mi peor día?',
      '¿A qué hora vendo más?',
      '¿Por qué los viernes vendo menos?',
      'Gráfica de mis ventas por hora',
    ],
    'clientes': [
      '¿Cuántos clientes tuve esta semana?',
      '¿Cuántos clientes nuevos tuve este mes?',
      '¿Qué clientes no han vuelto?',
      '¿Mis clientes frecuentes siguen viniendo?',
      '¿Cuánto me gasta en promedio cada cliente?',
    ],
    'tendencias': [
      '¿Estoy vendiendo más o menos que antes?',
      '¿Hubo algo raro esta semana?',
      '¿Cuál fue mi día más exitoso de todo el año?',
      '¿Cuándo fue la última vez que vendí más de \$500 en un día?',
      'Muéstrame una gráfica de mis ventas',
    ],
    'negocio': [
      '¿Cuánto me quedó limpio este mes?',
      '¿Gané o perdí comparado con el mes pasado?',
      '¿Estoy gastando bien en mercadería?',
      '¿Cuánto necesito vender para no perder?',
      '¿En qué estoy gastando más de lo que debería?',
      '¿Qué puedo hacer para ganar más sin vender más?',
      '¿Qué día debería hacer una promoción?',
      '¿Cómo puedo vender más?',
    ],
  };

  final List<String> _initialSuggestions = [
    '¿Cómo cobrar?',
    'Ver mi saldo',
    'Historial de pagos',
    'Soporte',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUserConversations();
  }

  Future<void> _loadUserConversations() async {
    final convs = await _messageService.getUserConversations(_userId);
    if (mounted) {
      setState(() {
        _conversations = convs;
      });
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final messages = await _messageService.getChatMessages(
        sessionId: _sessionId,
      );
      if (messages.isEmpty) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 400), () {
            _addBotMessage(
              '¡Hola Kevin! 👋 Soy **Lupita**, tu asistente de **JAMTECH**.\n\n'
              'Puedo ayudarte con:\n'
              '• Consultas sobre transacciones\n'
              '• Soporte para cobros y pagos\n'
              '• Información de tu cuenta\n'
              '• Reportes y estadísticas\n\n'
              '¿En qué puedo ayudarte hoy?',
            );
          });
        }
      } else {
        if (mounted) {
          setState(() {
            for (var msg in messages) {
              final isUser = msg.type == 'human';
              _messages.add(
                _ChatMessage(
                  text: msg.content,
                  isUser: isUser,
                  chartData: isUser ? null : ChartDataParser.parse(msg.content),
                ),
              );
            }
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        _addBotMessage(
          "¡Hola Kevin! Soy Lupita, tu asistente de JAMTECH. ¿En qué puedo ayudarte?",
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    final chartData = ChartDataParser.parse(text);
    final processedText = _processNumericContext(text);
    setState(() {
      _messages.add(_ChatMessage(text: processedText, isUser: false, chartData: chartData));
    });
    _scrollToBottom();
  }

  String _processNumericContext(String text) {
    final gainKeywords = ['ingreso', 'ganancia', 'ahorro', 'recibido', 'venta', 'vendi', 'vendí', 'exito', 'éxito', 'subio', 'subió', 'ganaste', 'positivo', 'mejorado', 'incremento'];
    final lossKeywords = ['gasto', 'perdida', 'pérdida', 'pago', 'pagado', 'deuda', 'perdi', 'perdí', 'bajo', 'bajó', 'perdiste', 'negativo', 'menos', 'disminución', 'reducción'];

    // Regex mejorada: opcionalmente inicia con - o +, opcional $, luego dígitos y decimales
    // Usamos límites que permiten signos pero evitan pegar números a otros dígitos (como fechas)
    return text.replaceAllMapped(RegExp(r'(?<![\d])([-+]?\$?\d+(?:[.,]\d+)?)(?![\d])'), (match) {
      final numStr = match.group(0)!;
      final index = match.start;
      
      // Si el número parece una fecha o parte de ella (ej: 2024-10-12), no lo resaltamos
      // El regex ya captura el guión si está al inicio, pero si está en medio de dígitos no.
      if (RegExp(r'^\d{2,4}-\d{2}-\d{2}$').hasMatch(numStr)) return numStr;

      // Ignorar números que parecen índices de lista (ej: "1. ", "2. ")
      if (text.substring(index + numStr.length).startsWith('. ')) return numStr;
      
      // Ignorar números aislados muy cortos sin contexto de moneda
      if (!numStr.contains('\$') && numStr.length < 2) return numStr;

      final start = (index - 60).clamp(0, text.length);
      final contextText = text.substring(start, index).toLowerCase();
      
      bool isLoss = numStr.startsWith('-') || lossKeywords.any((k) => contextText.contains(k));
      bool isGain = (numStr.startsWith('+') || gainKeywords.any((k) => contextText.contains(k))) && !numStr.startsWith('-');
      
      if (isGain) return '@G($numStr)@'; 
      if (isLoss) return '@L($numStr)@';
      return '**$numStr**';
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _addUserMessage(text);

    setState(() => _isTyping = true);

    try {
      final responseMsg = await _messageService.sendMessage(
        userId: _userId,
        sessionId: _sessionId,
        message: text,
      );

      if (mounted) {
        setState(() => _isTyping = false);
        _addBotMessage(responseMsg.content);
        _loadUserConversations(); // Actualizar el drawer
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _addBotMessage(
          "Hubo un error al procesar tu solicitud. Intenta nuevamente.",
        );
      }
    }
  }

  Future<void> _playAudio(String text, String messageId) async {
    if (_currentlyPlayingId == messageId) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingId = null);
      return;
    }

    setState(() => _currentlyPlayingId = messageId);

    try {
      final url = '${AppConstants.businessBotEndpoint}/tts?text=${Uri.encodeComponent(text)}';
      await _audioPlayer.play(UrlSource(url));

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _currentlyPlayingId = null);
      });
    } catch (e) {
      print('Error TTS: $e');
      setState(() => _currentlyPlayingId = null);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        setState(() => _isRecording = false);
        if (path != null) {
          _sendAudioForSTT(path);
        }
      } catch (e) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al detener grabación: $e')),
        );
      }
    } else {
      try {
        if (await _audioRecorder.hasPermission()) {
          if (kIsWeb) {
            await _audioRecorder.start(
              const RecordConfig(encoder: AudioEncoder.wav),
              path: '', // Requerido por el compilador, pero ignorado en la Web
            );
          } else {
            final tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
            await _audioRecorder.start(
              const RecordConfig(encoder: AudioEncoder.wav),
              path: path,
            );
          }
          setState(() => _isRecording = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de micrófono denegado.')),
          );
        }
      } catch (e) {
        print('Error al grabar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar micrófono: $e')),
        );
      }
    }
  }

  Future<void> _sendAudioForSTT(String path) async {
    setState(() => _isTyping = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.businessBotEndpoint}/stt'),
      );
      
      if (path.startsWith('blob:')) {
        var audioResponse = await http.get(Uri.parse(path));
        request.files.add(http.MultipartFile.fromBytes('file', audioResponse.bodyBytes, filename: 'audio.wav'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', path));
      }
      
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        String text = data['text'] ?? '';
        if (text.isNotEmpty) {
          _messageController.text = text;
          _sendMessage();
        }
      } else {
        var responseData = await response.stream.bytesToString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error STT (${response.statusCode}): $responseData')),
          );
        }
      }
    } catch (e) {
      print('Error STT: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión STT: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: _buildHistoryDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Avatar bot
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lupita',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'En línea',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Badge IA
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'IA',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history_rounded, color: Colors.white),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // ── Lista de mensajes ─────────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // ── Sugerencias rápidas ───────────────────────────────────────
          if (_messages.isNotEmpty && !_messages.last.isUser) _buildQuickSuggestions(),

          // ── Input de mensaje ──────────────────────────────────────────
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lupita',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [AppColors.primaryLight, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  child: MarkdownBody(
                    data: message.text,
                    extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                      [
                        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                        ColorAmountSyntax(),
                      ],
                    ),
                    builders: {
                      'amount_G': ColorAmountBuilder(const Color(0xFF10B981)),
                      'amount_L': ColorAmountBuilder(const Color(0xFFEF4444)),
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.5,
                      ),
                      listBullet: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.textPrimary,
                      ),
                      strong: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Gráfico interactivo (solo para mensajes del bot con datos)
                if (!isUser && message.chartData != null)
                  ChatChartWidget(data: message.chartData!),
              ],
            ),
          ),
          if (!isUser) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _playAudio(message.text, message.id),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_currentlyPlayingId == message.id)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _currentlyPlayingId == message.id
                          ? AppColors.primary
                          : AppColors.primarySurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Icon(
                      _currentlyPlayingId == message.id
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      color: _currentlyPlayingId == message.id
                          ? Colors.white
                          : AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isUser) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'K',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kevin',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 150),
                const SizedBox(width: 4),
                _TypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getDynamicSuggestions() {
    if (_messages.isEmpty) return _initialSuggestions;

    // Obtener el texto del último mensaje (del bot o usuario)
    final lastText = _messages.last.text.toLowerCase();
    
    String category = 'general';
    
    // Detección simple de palabras clave
    if (lastText.contains('vendi') || lastText.contains('venta') || lastText.contains('ingreso') || lastText.contains('dinero') || lastText.contains('resumen')) {
      category = 'ventas';
    } else if (lastText.contains('hora') || lastText.contains('dia') || lastText.contains('lunes') || lastText.contains('viernes') || lastText.contains('semana')) {
      category = 'tiempo';
    } else if (lastText.contains('cliente') || lastText.contains('persona') || lastText.contains('frecuente')) {
      category = 'clientes';
    } else if (lastText.contains('mas') || lastText.contains('menos') || lastText.contains('raro') || lastText.contains('tendencia')) {
      category = 'tendencias';
    } else if (lastText.contains('gasto') || lastText.contains('perdi') || lastText.contains('gane') || lastText.contains('limpio') || lastText.contains('promocion')) {
      category = 'negocio';
    }

    List<String> pool = [];
    if (category == 'general') {
      // Si no hay contexto claro, mezclar una de cada categoría
      pool = [
        _suggestionCategories['ventas']![Random().nextInt(_suggestionCategories['ventas']!.length)],
        _suggestionCategories['clientes']![Random().nextInt(_suggestionCategories['clientes']!.length)],
        _suggestionCategories['negocio']![Random().nextInt(_suggestionCategories['negocio']!.length)],
        _initialSuggestions[Random().nextInt(_initialSuggestions.length)],
      ];
    } else {
      // Tomar 3 de la categoría detectada y 1 general
      final catList = List<String>.from(_suggestionCategories[category]!);
      catList.shuffle();
      pool = catList.take(3).toList();
      pool.add(_initialSuggestions[Random().nextInt(_initialSuggestions.length)]);
    }

    return pool;
  }

  Widget _buildQuickSuggestions() {
    final suggestions = _getDynamicSuggestions();

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _messageController.text = suggestions[index];
              _sendMessage();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                suggestions[index],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón Micrófono
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isRecording)
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 2,
                  ),
                ),
              GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: _isRecording ? Colors.white : AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Botón enviar
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Historial de Chats',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _sessionId = const Uuid().v4();
                    _messages.clear();
                  });
                  Navigator.pop(context); // close drawer
                  _loadChatHistory();
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'Nueva Conversación',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: _conversations.isEmpty
                  ? Center(
                      child: Text(
                        'No hay conversaciones previas',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conv = _conversations[index];
                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                          title: Text(
                            conv.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${conv.updatedAt.day}/${conv.updatedAt.month}/${conv.updatedAt.year}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _confirmDeleteConversation(conv.sessionId),
                          ),
                          onTap: () {
                            setState(() {
                              _sessionId = conv.sessionId;
                              _messages.clear();
                            });
                            Navigator.pop(context);
                            _loadChatHistory();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteConversation(String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar Chat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar este chat?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _messageService.deleteConversation(sessionId);
              if (success) {
                if (_sessionId == sessionId) {
                  setState(() {
                    _sessionId = const Uuid().v4();
                    _messages.clear();
                  });
                  _loadChatHistory();
                }
                _loadUserConversations();
              }
            },
            child: Text('Eliminar', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final ParsedChartData? chartData;
  _ChatMessage({required this.text, required this.isUser, String? id, this.chartData})
    : id = id ?? const Uuid().v4();
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ColorAmountBuilder extends MarkdownElementBuilder {
  final Color color;
  ColorAmountBuilder(this.color);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text(
      element.textContent,
      style: preferredStyle?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class ColorAmountSyntax extends md.InlineSyntax {
  ColorAmountSyntax() : super(r'@(G|L)\(([^)]+)\)@');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final type = match.group(1); // G o L
    final text = match.group(2); // El número
    final element = md.Element.text('amount_$type', text!);
    parser.addNode(element);
    return true;
  }
}
