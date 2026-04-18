class Photo {
  final String path;
  final String name;
  final String confidence;

  Photo({
    required this.path,
    required this.name,
    required this.confidence,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      path: json['image_url'].toString(),
      name: json['class_name']?.toString() ?? '',
      confidence: json['confidence']?.toString() ?? '',
    );
  }

}