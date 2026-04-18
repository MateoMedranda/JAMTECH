import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageProvider extends ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> get messages => _messages;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void addMessages(List<Message> newMessages) {
    _messages.addAll(newMessages);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
