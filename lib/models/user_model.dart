/// Modelo de Usuario del sistema
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.avatar,
  });

  // Crear desde JSON (respuesta de la API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  // Convertir a JSON (para guardar localmente)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'avatar': avatar,
    };
  }

  // Crear copia con modificaciones
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }
}
