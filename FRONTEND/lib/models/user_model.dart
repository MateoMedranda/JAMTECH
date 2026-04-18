class UserModel {
  final String? id;
  final String nombre;
  final String email;
  final String password;
  final String birthdate;
  final String gender;
  final double? weight;
  final double? height;
  final String? medicalConditions;
  final String? medications;
  final String? allergies;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.birthdate,
    required this.gender,
    this.weight,
    this.height,
    this.medicalConditions,
    this.medications,
    this.allergies,
  });

  // Convertir de JSON a modelo
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      birthdate: json['birthdate']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      medicalConditions: json['medical_conditions']?.toString(),
      medications: json['medications']?.toString(),
      allergies: json['allergies']?.toString(),
    );
  }

  // Convertir de modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'password': password,
      'birthdate': birthdate,
      'gender': gender,
      'weight': weight,
      'height': height,
      'medical_conditions': medicalConditions,
      'medications': medications,
      'allergies': allergies,
    };
  }
}
