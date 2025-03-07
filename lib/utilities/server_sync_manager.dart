import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerSyncManager {
  static const String _serverPort = "8000";
  static String _serverIp = '';
  
  static String get serverAddress => _serverIp;
  static set serverAddress(String value) {
    // Убираем порт из адреса, если он был введен
    _serverIp = value.trim().split(':')[0];
  }

  static String get serverUrl => 'http://$_serverIp:$_serverPort';

  static Future<Map<String, dynamic>> syncFromServer() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/sync'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Ошибка получения данных: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> syncToServer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Ошибка отправки данных: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }
} 