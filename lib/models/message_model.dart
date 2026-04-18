class Message {
  final String type;
  final String content;
  final String? imageUrl;

  Message({required this.type, required this.content, this.imageUrl});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      type: json['type'].toString(),
      content: json['content']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }

  factory Message.fromBotResponse(Map<String, dynamic> json) {
    return Message(type: 'ai', content: json['content']?.toString() ?? '');
  }
}
