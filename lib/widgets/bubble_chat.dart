import 'package:flutter/material.dart';
import 'dart:io';

class BubbleChat extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final File? imageFile;
  final String? imageUrl;

  const BubbleChat({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    this.imageFile,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageFile != null || imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageFile != null
                    ? Image.file(
                        imageFile!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50, color: Colors.white70),
                      ),
              ),
              const SizedBox(height: 8),
            ],
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}