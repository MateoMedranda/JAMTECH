import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../services/chat_history_service.dart';
import '../controllers/auth_controller.dart';
import '../views/chat_view.dart';
import 'package:provider/provider.dart';

class ScanHistoryDrawer extends StatefulWidget {
  const ScanHistoryDrawer({super.key});

  @override
  State<ScanHistoryDrawer> createState() => _ScanHistoryDrawerState();
}

class _ScanHistoryDrawerState extends State<ScanHistoryDrawer> {
  late Future<List<ChatHistory>> _historyFuture;
  final ChatHistoryService _service = ChatHistoryService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final authController = context.read<AuthController>();
    final userId = authController.currentUser?.email ?? 'unknown';
    _historyFuture = _service.obtenerHistorial(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor:
          Theme.of(context).drawerTheme.backgroundColor ??
          AppColors.primaryLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _loadHistory();
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
            // 🔹 LISTA DE CONVERSACIONES
            Expanded(
              child: FutureBuilder<List<ChatHistory>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No hay conversaciones aún',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }

                  final conversations = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final chat = conversations[index];
                      return Dismissible(
                        key: Key(chat.conversationId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          final success = await _service.eliminarConversacion(
                            chat.conversationId,
                          );

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Conversación eliminada'),
                                ),
                              );
                              setState(() {
                                _loadHistory();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al eliminar'),
                                ),
                              );
                            }
                          }
                        },
                        confirmDismiss: (direction) async {
                          return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar conversación'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas eliminar esta conversación de forma permanente?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        child: ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(
                            chat.diagnosis.length > 30
                                ? '${chat.diagnosis.substring(0, 27)}...'
                                : chat.diagnosis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            chat.formattedDate,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final confirm =
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Eliminar conversación',
                                      ),
                                      content: const Text(
                                        '¿Estás seguro de que deseas eliminar esta conversación de forma permanente?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirm) {
                                final success = await _service
                                    .eliminarConversacion(chat.conversationId);

                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Conversación eliminada'),
                                      ),
                                    );
                                    setState(() {
                                      _loadHistory();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error al eliminar'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          onTap: () {
                            final authController = context
                                .read<AuthController>();
                            final userId =
                                authController.currentUser?.email ?? 'unknown';

                            Navigator.pop(context); // Cerrar el drawer

                            // Navegar a ChatView
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatView(
                                  sessionId: chat.conversationId,
                                  userId: userId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'HealthfyAI © 2026',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
