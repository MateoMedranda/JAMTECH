import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';
import '../config/constants.dart';
import 'api_service.dart';

class PhotoDetectionService {
  Future<Photo?> detectPhoto({
    required String filePath,
    required String userId,
    required String conversationId,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.imagePredictionEndpoint}/detect-image?user_id=$userId&conversation_id=$conversationId',
      );

      final request = http.MultipartRequest('POST', uri);
      if (ApiService.authToken != null) {
        request.headers['Authorization'] = 'Bearer ${ApiService.authToken}';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String imageUrl = data['image_url'];
        final String fullUrl = imageUrl.startsWith('http')
            ? imageUrl
            : '${AppConstants.baseUrl}/$imageUrl';
        return Photo(
          path: fullUrl,
          name: data['class_name'] ?? '',
          confidence: 'Confianza: ${data['confidence']}',
        );
      }
    } catch (e) {
      //
    }
    return null;
  }
}
