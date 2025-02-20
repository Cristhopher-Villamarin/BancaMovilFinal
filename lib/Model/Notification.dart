import 'package:banca_movil_final/Model/UserI.dart';

class NotificationI {
  final int id;
  final UserI user;
  final String message;
  bool read;

  NotificationI({
    required this.id,
    required this.user,
    required this.message,
    required this.read,
  });

  // Método para convertir un JSON a un objeto NotificationI
  factory NotificationI.fromJson(Map<String, dynamic> json) {
    return NotificationI(
      id: json['id'] as int,
      user: UserI.fromJson(json['user']), // Convertir el JSON de usuario a UserI
      message: json['message'] as String,
      read: json['read'] as bool,
    );
  }

  // Método para convertir un objeto NotificationI a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(), // Convertir UserI a JSON
      'message': message,
      'read': read,
    };
  }
}
