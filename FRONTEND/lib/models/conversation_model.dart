class Conversation {
  final String id;
  final String sessionId;
  final String userId;
  final String title;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.title,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Conversación',
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }
}
