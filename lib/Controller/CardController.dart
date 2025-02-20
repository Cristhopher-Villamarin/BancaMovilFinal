import 'dart:convert';
import 'package:banca_movil_final/Model/CardUser.dart'; // Asegúrate de tener esta clase Card
import 'package:http/http.dart' as http;

class CardController {
  static const String _apiUrl = "localhost:9092"; // Asegúrate de usar el puerto adecuado

  // Método para obtener las tarjetas de un usuario
  static Future<List<CardUser>?> getCardsByUser(int userId) async {
    var url = Uri.http(_apiUrl, "/cards/$userId");
    List<CardUser> cards = [];

    try {
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        cards = jsonResponse.map((card) => CardUser.fromJson(card)).toList();
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }

    return cards;
  }

  // Método para agregar una tarjeta
  static Future<CardUser?> addCard(CardUser card) async {
    var url = Uri.http(_apiUrl, "/cards/add");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(card.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CardUser.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Método para congelar una tarjeta
  static Future<CardUser?> freezeCard(int cardId) async {
    var url = Uri.http(_apiUrl, "/cards/freeze/$cardId");

    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CardUser.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Método para descongelar una tarjeta
  static Future<CardUser?> unfreezeCard(int cardId) async {
    var url = Uri.http(_apiUrl, "/cards/unfreeze/$cardId");

    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CardUser.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
