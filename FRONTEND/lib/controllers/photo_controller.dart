import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_controller.dart';
import '../providers/photo_provider.dart';
import '../services/photo_detection_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PhotoController {
  final PhotoProvider provider;
  final ImagePicker picker = ImagePicker();
  final PhotoDetectionService service = PhotoDetectionService();

  PhotoController(this.provider);

  Future<void> tomarFoto(BuildContext context) async {
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto == null) {
      return;
    }

    // Obtener el userId del usuario autenticado antes del async gap
    final authController = context.read<AuthController>();
    final userId = authController.currentUser?.email ?? 'unknown';

    // Generar un ID único para esta conversación
    const uuid = Uuid();
    final conversationId = uuid.v4();

    provider.setAnalyzing(true);

    try {
      final detectedPhoto = await service.detectPhoto(
        filePath: foto.path,
        userId: userId,
        conversationId: conversationId,
      );

      if (detectedPhoto != null) {
        provider.takePhoto(
          detectedPhoto,
          conversationId: conversationId,
          userId: userId,
        );

        // Guardar el resultado del análisis para usar en el chat
        // Extraer el confidence del formato "Confianza: X"
        final confidenceStr = detectedPhoto.confidence.replaceAll(
          'Confianza: ',
          '',
        );
        final confidenceValue = double.tryParse(confidenceStr) ?? 0.0;

        provider.setAnalysisResult(
          diagnosis: detectedPhoto.name,
          confidence: confidenceValue,
          imageUrl: detectedPhoto.path,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al analizar la imagen')),
          );
        }
        provider.setAnalyzing(false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      provider.setAnalyzing(false);
    }
  }
}
