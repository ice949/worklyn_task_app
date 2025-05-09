import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  static Future<Map<String, dynamic>> sendMessage({
    required String text,
    required String? userId,
  }) async {
    final headers = {
      'X-Environment': 'development',
      'Content-Type': 'application/json',
      if (userId != null) 'cookie': 'id=$userId',
    };

    final response = await http.put(
      Uri.parse('https://api.worklyn.com/konsul/assistant.chat'),
      headers: headers,
      body: jsonEncode({
        "message": text,
        "source": {"id": "1", "deviceId": 1},
      }),
    );

    return jsonDecode(response.body);
  }
}
