import 'package:banca_movil_final/Model/Payment.dart';

class Transaction {
  final int id;
  final Payment payment; // Relación Many-to-One con Payment
  final String type;
  final String accountNumber;
  final DateTime transactionDate;
  final double amount;

  Transaction({
    required this.id,
    required this.payment,
    required this.type,
    required this.accountNumber,
    required this.transactionDate,
    required this.amount,
  });

  // Método para convertir un JSON a un objeto Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      type: json['type'] as String,
      accountNumber: json['accountNumber'] as String,
      transactionDate: DateTime.parse(json['transactionDate']),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  // Método para convertir un objeto Transaction a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment': payment.toJson(),
      'type': type,
      'accountNumber': accountNumber,
      'transactionDate': transactionDate.toIso8601String(),
      'amount': amount,
    };
  }
}
