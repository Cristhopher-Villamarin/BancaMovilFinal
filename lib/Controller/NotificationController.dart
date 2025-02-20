import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:banca_movil_final/Model/Notification.dart';

class NotificationController {
  static const String _apiUrl = "localhost:9092";

  // Obtener notificaciones de un usuario
  static Future<List<NotificationI>?> getUserNotifications(int userId) async {
    var url = Uri.http(_apiUrl, "notifications/$userId");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return jsonResponse.map((e) => NotificationI.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Marcar una notificación como leída
  static Future<bool> markNotificationAsRead(int notificationId) async {
    var url = Uri.http(_apiUrl, "notifications/mark-as-read/$notificationId");
    try {
      var response = await http.put(url);
      return response.statusCode == 204;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Contar notificaciones no leídas de un usuario
  static Future<int?> countNotificationNoRead(int userId) async {
    var url = Uri.http(_apiUrl, "notifications/countNotificationNoRead/$userId");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Marcar todas las notificaciones como leídas
  static Future<bool> markAllNotificationsAsRead(int userId) async {
    var url = Uri.http(_apiUrl, "notifications/mark-all-as-read/$userId");
    try {
      var response = await http.put(url);
      return response.statusCode == 204;
    } catch (e) {
      print(e);
    }
    return false;
  }
}
