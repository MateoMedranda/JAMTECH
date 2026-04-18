import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/photo_provider.dart';

class BigPhotoBox extends StatelessWidget {
  const BigPhotoBox({super.key});

  @override
  Widget build(BuildContext context) {
    final photo = context.watch<PhotoProvider>().foto;

    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: photo == null
          ? const Center(
              child: Icon(Icons.camera_alt, size: 60, color: Colors.grey),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  photo.path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
    );
  }
}
