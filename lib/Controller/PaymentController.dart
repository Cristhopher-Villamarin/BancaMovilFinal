import 'dart:convert';
import 'package:banca_movil_final/Model/Payment.dart';
import 'package:http/http.dart' as http;

class PaymentController {
  static const String _apiUrl = "localhost:9092"; // Ajusta según tu servidor

  static Future<Payment?> processPayment(Payment payment) async {
    var url = Uri.http(_apiUrl, "payments/pay");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payment.toJson()), // Convierte el objeto Payment a JSON
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Payment.fromJson(jsonResponse); // Retorna el objeto Payment
      } else {
        return null; // Error en la petición
      }
    } catch (e) {
      print("Error en la petición: $e");
      return null;
    }
  }
}
