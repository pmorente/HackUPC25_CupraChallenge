import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://10.192.170.55:5000'; // Your server's IP address
  // static const String baseUrl = 'http://localhost:5000'; // For iOS simulator

  // Process data using Python
  static Future<Map<String, dynamic>> processData(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/process-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to process data');
    }
  }

  // Analyze data using Python
  static Future<Map<String, dynamic>> analyzeData(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/analyze-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze data');
    }
  }
}
