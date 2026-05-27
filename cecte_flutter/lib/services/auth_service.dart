import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String kBaseUrl = 'http://127.0.0.1:8000/api';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _usuario;
  bool _isLoading = true;

  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  String get token => _token ?? '';
  Map<String, dynamic>? get usuario => _usuario;
  bool get esAdmin => _usuario?['rol'] == 'admin';
  bool get esEstudiante => _usuario?['rol'] == 'estudiante';
  String get nombreUsuario => _usuario?['first_name'] ?? _usuario?['username'] ?? '';

  AuthService() {
    _cargarTokenGuardado();
  }

  Future<void> _cargarTokenGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    if (savedToken != null) {
      _token = savedToken;
      await _cargarPerfil();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cargarPerfil() async {
    try {
      final resp = await http.get(
        Uri.parse('$kBaseUrl/auth/perfil/'),
        headers: _headers(),
      );
      if (resp.statusCode == 200) {
        _usuario = jsonDecode(resp.body);
      } else {
        await logout();
      }
    } catch (_) {
      await logout();
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _token = data['token'];
        _usuario = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        notifyListeners();
        return null;
      } else {
        final data = jsonDecode(resp.body);
        return data['error']?.toString() ?? 'Credenciales incorrectas.';
      }
    } catch (e) {
      return 'Error de conexion con el servidor.';
    }
  }

  Future<String?> registrarEstudiante(Map<String, dynamic> datos) async {
    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/auth/registro/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        _token = data['token'];
        _usuario = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        notifyListeners();
        return null;
      } else {
        final data = jsonDecode(resp.body);
        return data.values.first.toString();
      }
    } catch (e) {
      return 'Error de conexion con el servidor.';
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$kBaseUrl/auth/logout/'),
          headers: _headers(),
        );
      } catch (_) {}
    }
    _token = null;
    _usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $_token',
  };
}