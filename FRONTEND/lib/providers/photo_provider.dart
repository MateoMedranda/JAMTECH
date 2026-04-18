import 'package:flutter/material.dart';
import '../models/photo_model.dart';

class PhotoProvider extends ChangeNotifier {
  Photo? _foto;
  String? _conversationId;
  String? _userId;
  bool _isAnalyzing = false;

  // Análisis de imagen
  String? _diagnosis;
  double? _confidence;
  String? _imageUrl;
  bool _initialMessageSent = false;

  Photo? get foto => _foto;
  String? get conversationId => _conversationId;
  String? get userId => _userId;
  bool get isAnalyzing => _isAnalyzing;

  String? get diagnosis => _diagnosis;
  double? get confidence => _confidence;
  String? get imageUrl => _imageUrl;
  bool get initialMessageSent => _initialMessageSent;

  void setInitialMessageSent(bool value) {
    _initialMessageSent = value;
    notifyListeners();
  }

  void takePhoto(
    Photo foto, {
    required String conversationId,
    required String userId,
  }) {
    _foto = foto;
    _conversationId = conversationId;
    _userId = userId;
    _isAnalyzing = false;
    notifyListeners();
  }

  void setAnalysisResult({
    required String diagnosis,
    required double confidence,
    required String imageUrl,
  }) {
    _diagnosis = diagnosis;
    _confidence = confidence;
    _imageUrl = imageUrl;
    notifyListeners();
  }

  void setAnalyzing(bool value) {
    _isAnalyzing = value;
    notifyListeners();
  }

  void setConversation({
    required String conversationId,
    required String userId,
  }) {
    _conversationId = conversationId;
    _userId = userId;
    notifyListeners();
  }

  void clearPhoto() {
    _foto = null;
    _conversationId = null;
    _userId = null;
    _isAnalyzing = false;
    _diagnosis = null;
    _confidence = null;
    _imageUrl = null;
    _initialMessageSent = false;
    notifyListeners();
  }
}
