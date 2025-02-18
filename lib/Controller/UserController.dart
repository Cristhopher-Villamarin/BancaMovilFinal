import 'dart:convert';

import 'package:banca_movil_final/Model/UserI.dart';
import 'package:http/http.dart' as http;

class UserController {
  static const String _apiUrl = "localhost:9092";

  static Future<UserI?> registerOrLoginUser(UserI userI) async {
    var url = Uri.http(_apiUrl, "users/registerOrLogin");
    UserI userLogin;
    try {
      var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(userI.toJson()));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if(response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        userLogin = UserI.fromJson(jsonResponse);
      } else {
        return null;
      }

    } catch (e) {
      print(e);
      return null;
    }

    return userLogin;
  }
}