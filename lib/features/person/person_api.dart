import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonApi {
  Future<Map<String, dynamic>> fetchUserInfo(String userId) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/user/' + userId),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user info');
    }
  }
}
