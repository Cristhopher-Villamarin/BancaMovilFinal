import 'package:banca_movil_final/Model/UserI.dart';

class Payment {
  final int id;
  final UserI user; // Relación Many-to-One con la clase UserI
  final double amount;
  final String numeroCuentaDestino;
  final DateTime paymentDate;

  Payment({
    required this.id,
    required this.user,
    required this.amount,
    required this.numeroCuentaDestino,
    required this.paymentDate,
  });

  // Método para convertir un JSON a un objeto Payment
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      user: UserI.fromJson(json['user'] as Map<String, dynamic>), // Deserializa el usuario
      amount: (json['amount'] as num).toDouble(),
      numeroCuentaDestino: json['numeroCuentaDestino'] as String,
      paymentDate: DateTime.parse(json['paymentDate']), // Convierte string a DateTime
    );
  }

  // Método para convertir un objeto Payment a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(), // Convierte el objeto UserI a JSON
      'amount': amount,
      'numeroCuentaDestino': numeroCuentaDestino,
      'paymentDate': paymentDate.toIso8601String(), // Convierte DateTime a string ISO
    };
  }
}
