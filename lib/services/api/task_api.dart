import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskApi {
  static Future<List<Map<String, dynamic>>> fetchTasks(String userId) async {
    final url = Uri.parse('https://api.worklyn.com/konsul/actionPoints.list');
    final resp = await http.get(url, headers: {
      'X-Environment': 'development',
      'Cookie': 'id=$userId',
      'content-type': 'application/json',
    });
    if (resp.statusCode != 200) {
      throw Exception('Failed to load tasks: ${resp.statusCode}');
    }
    final body = json.decode(resp.body);
    return List<Map<String, dynamic>>.from(body['data']['points']);
  }
}
