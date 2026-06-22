import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegistroPublicoScreen extends StatefulWidget {
  const RegistroPublicoScreen({super.key});

  @override
  State<RegistroPublicoScreen> createState() => _RegistroPublicoScreenState();
}

class _RegistroPublicoScreenState extends State<RegistroPublicoScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _telefonoCtrl  = TextEditingController();

  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  static const Color kPrimary = Color(0xFF0A6E7A);

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
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthService>();
    final error = await auth.registrarEstudiante({
      'username':   _usernameCtrl.text.trim(),
      'password':   _passwordCtrl.text,
      'first_name': _firstNameCtrl.text.trim(),
      'last_name':  _lastNameCtrl.text.trim(),
      'email':      _emailCtrl.text.trim().toLowerCase(),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Encabezado ──────────────────────────────────
                      Row(children: [
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
                      ]),
                      const SizedBox(height: 4),
                      const Text(
                        'El programa académico lo asigna el administrador después de tu registro.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),

                      // ── Datos personales ─────────────────────────────
                      _seccion('Datos Personales'),
                      const SizedBox(height: 12),

                      _campo(
                        ctrl: _firstNameCtrl,
                        label: 'Nombres *',
                        icon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'El nombre es obligatorio';
                          if (v.trim().length < 2)
                            return 'Mínimo 2 caracteres';
                          if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(v.trim()))
                            return 'Solo se permiten letras';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _campo(
                        ctrl: _lastNameCtrl,
                        label: 'Apellidos *',
                        icon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'El apellido es obligatorio';
                          if (v.trim().length < 2)
                            return 'Mínimo 2 caracteres';
                          if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(v.trim()))
                            return 'Solo se permiten letras';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _campo(
                        ctrl: _documentoCtrl,
                        label: 'Número de documento *',
                        icon: Icons.badge_outlined,
                        tipo: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'El documento es obligatorio';
                          if (v.trim().length < 6)
                            return 'Mínimo 6 dígitos';
                          if (v.trim().length > 15)
                            return 'Máximo 15 dígitos';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _campo(
                        ctrl: _emailCtrl,
                        label: 'Correo electrónico *',
                        icon: Icons.email_outlined,
                        tipo: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'El correo es obligatorio';
                          if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$')
                              .hasMatch(v.trim()))
                            return 'Formato de correo inválido (ej: nombre@correo.com)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _campo(
                        ctrl: _telefonoCtrl,
                        label: 'Teléfono (opcional)',
                        icon: Icons.phone_outlined,
                        tipo: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (v.trim().length < 7)
                            return 'Mínimo 7 dígitos';
                          if (v.trim().length > 15)
                            return 'Máximo 15 dígitos';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // ── Datos de acceso ──────────────────────────────
                      _seccion('Datos de Acceso'),
                      const SizedBox(height: 12),

                      _campo(
                        ctrl: _usernameCtrl,
                        label: 'Nombre de usuario *',
                        icon: Icons.account_circle_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'El usuario es obligatorio';
                          if (v.trim().length < 4)
                            return 'Mínimo 4 caracteres';
                          if (v.trim().length > 20)
                            return 'Máximo 20 caracteres';
                          if (!RegExp(r'^[a-zA-Z0-9_\.]+$').hasMatch(v.trim()))
                            return 'Solo letras, números, _ y .';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Campo contraseña (con validator manual)
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: kPrimary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'La contraseña es obligatoria';
                          if (v.length < 6)
                            return 'Mínimo 6 caracteres';
                          if (v.length > 30)
                            return 'Máximo 30 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // ── Error del servidor ───────────────────────────
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFDC2626), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 13)),
                            ),
                          ]),
                        ),

                      const SizedBox(height: 20),

                      // ── Botón ────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _registrar,
                          child: _loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Crear cuenta',
                                style: TextStyle(
                                    fontSize: 15,
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
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Text(titulo,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            fontSize: 13));
  }

  Widget _campo({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
    );
  }
}