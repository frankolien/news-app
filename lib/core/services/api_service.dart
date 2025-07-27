import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  final String baseUrl = 'https://api.agcnewsnet.com'; 
  
  Future<dynamic> get(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      print('Making API call to: $url'); 
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return _convertToStringKeyMap(decoded);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
  
  // Helper method to convert Map<dynamic, dynamic> to Map<String, dynamic>
  dynamic _convertToStringKeyMap(dynamic item) {
    if (item is Map) {
      return Map<String, dynamic>.from(
        item.map((key, value) => MapEntry(key.toString(), _convertToStringKeyMap(value)))
      );
    } else if (item is List) {
      return item.map((element) => _convertToStringKeyMap(element)).toList();
    }
    return item;
  }
}
