import 'package:banca_movil_final/Model/UserI.dart';

class CardUser {
  final int id;
  final UserI user; // Aquí tienes una relación Many-to-One con la clase UserI
  final String cardNumber;
  final bool frozen;

  CardUser({
    required this.id,
    required this.user,
    required this.cardNumber,
    required this.frozen,
  });

  // Método para convertir un JSON a un objeto Card
  factory CardUser.fromJson(Map<String, dynamic> json) {
    return CardUser(
      id: json['id'] as int,
      user: UserI.fromJson(json['user'] as Map<String, dynamic>), // Deserializa el usuario
      cardNumber: json['cardNumber'] as String,
      frozen: json['frozen'] as bool,
    );
  }

  // Método para convertir un objeto Card a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(), // Convierte el objeto UserI a JSON
      'cardNumber': cardNumber,
      'frozen': frozen,
    };
  }
}
