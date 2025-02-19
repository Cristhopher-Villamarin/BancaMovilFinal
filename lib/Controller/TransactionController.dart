import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:banca_movil_final/Model/Transaction.dart';

class TransactionController {
  static const String _apiUrl = "localhost:9092";

  static Future<List<Transaction>> getTransactionsByAccount(String accountNumber) async {
    var url = Uri.http(_apiUrl, "transactions/$accountNumber");
    List<Transaction> transactions = [];

    try {
      var response = await http.get(url, headers: {"Content-Type": "application/json"});

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        transactions = jsonResponse.map((data) => Transaction.fromJson(data)).toList();
      }
    } catch (e) {
      print("Error al obtener transacciones: $e");
    }

    return transactions;
  }
}
