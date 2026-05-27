import 'dart:convert';
import 'package:http/http.dart' as http;

const String kBaseUrl = 'http://127.0.0.1:8000/api';

class ApiService {
  final String token;
  ApiService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $token',
  };

  Future get(String endpoint) async {
    final resp = await http.get(
      Uri.parse('$kBaseUrl/$endpoint'),
      headers: _headers,
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception(resp.body);
  }

  Future post(String endpoint, Map data) async {
    final resp = await http.post(
      Uri.parse('$kBaseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body);
    }
    throw Exception(resp.body);
  }

  Future put(String endpoint, Map data) async {
    final resp = await http.put(
      Uri.parse('$kBaseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception(resp.body);
  }

  Future delete(String endpoint) async {
    final resp = await http.delete(
      Uri.parse('$kBaseUrl/$endpoint'),
      headers: _headers,
    );
    if (resp.statusCode == 200 || resp.statusCode == 204) return true;
    throw Exception(resp.body);
  }
}