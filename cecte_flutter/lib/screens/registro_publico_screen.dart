import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegistroPublicoScreen extends StatefulWidget {
  const RegistroPublicoScreen({super.key});

  @override
  State<RegistroPublicoScreen> createState() => _RegistroPublicoScreenState();
}

class _RegistroPublicoScreenState extends State<RegistroPublicoScreen> {
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _telefonoCtrl  = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _documentoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _documentoCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos obligatorios.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthService>();
    final error = await auth.registrarEstudiante({
      'username':   _usernameCtrl.text.trim(),
      'password':   _passwordCtrl.text,
      'first_name': _firstNameCtrl.text.trim(),
      'last_name':  _lastNameCtrl.text.trim(),
      'email':      _emailCtrl.text.trim(),
      'documento':  _documentoCtrl.text.trim(),
      'telefono':   _telefonoCtrl.text.trim(),
    });
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() { _loading = false; _error = error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF042F35),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Registro de Estudiante',
                              style: TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'El programa academico lo asigna el administrador despues de tu registro.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    _campo(_firstNameCtrl, 'Nombres *', Icons.person_outline),
                    const SizedBox(height: 12),
                    _campo(_lastNameCtrl, 'Apellidos *', Icons.person_outline),
                    const SizedBox(height: 12),
                    _campo(_documentoCtrl, 'Numero de documento *', Icons.badge_outlined),
                    const SizedBox(height: 12),
                    _campo(_emailCtrl, 'Correo electronico *', Icons.email_outlined,
                        tipo: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _campo(_telefonoCtrl, 'Telefono (opcional)', Icons.phone_outlined,
                        tipo: TextInputType.phone),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text('Datos de acceso',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    _campo(_usernameCtrl, 'Nombre de usuario *',
                        Icons.account_circle_outlined),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Contrasena *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF0A6E7A), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFDC2626), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(
                                      color: Color(0xFFDC2626), fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registrar,
                        child: _loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Crear cuenta',
                                style: TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0A6E7A), width: 2),
        ),
      ),
    );
  }
}