import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RangeService {
  // Base URL for your deployed PythonAnywhere server
  static const String _baseUrl = 'https://mtalha4t7.pythonanywhere.com';

  Future<Map<String, dynamic>> predictRange({
    required double acceleration,
    required double topSpeed,
    required double batteryCapacity,
    required int seats,
    required String drive,
  }) async {
    final url = Uri.parse('$_baseUrl/predict');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'acceleration': acceleration,
      'top_speed': topSpeed,
      'battery_capacity': batteryCapacity,
      'seats': seats,
      'drive': drive,
    });

    debugPrint('Sending request to: $url');
    debugPrint('Request body: $body');

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));
      debugPrint('Status check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Server check failed: $e');
      return false;
    }
  }
}
