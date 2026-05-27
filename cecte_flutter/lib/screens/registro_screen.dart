import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class RegistroScreen extends StatefulWidget {
  final VoidCallback? onRegistrado;
  const RegistroScreen({super.key, this.onRegistrado});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _nombre   = TextEditingController();
  final _doc      = TextEditingController();
  final _correo   = TextEditingController();
  final _tel      = TextEditingController();

  List<dynamic> _programas   = [];
  int?          _programaId;
  bool          _cargando    = false;
  bool          _cargandoProg= true;
  String?       _error;
  String?       _exito;

  @override
  void initState() {
    super.initState();
    _cargarProgramas();
  }

  @override
  void dispose() {
    _nombre.dispose(); _doc.dispose();
    _correo.dispose(); _tel.dispose();
    super.dispose();
  }

  Future<void> _cargarProgramas() async {
    final token = context.read<AuthService>().token;
    try {
      final data = await ApiService(token).get('programas/');
      final lista = (data is Map) ? (data['results'] ?? data) : data;
      if (mounted) setState(() { _programas = lista; _cargandoProg = false; });
    } catch (_) {
      if (mounted) setState(() => _cargandoProg = false);
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_programaId == null) {
      setState(() => _error = 'Seleccione un programa.');
      return;
    }
    setState(() { _cargando = true; _error = null; _exito = null; });
    final token = context.read<AuthService>().token;
    try {
      final resp = await ApiService(token).post('estudiantes/', {
        'nombre':    _nombre.text.trim(),
        'documento': _doc.text.trim(),
        'correo':    _correo.text.trim().toLowerCase(),
        'telefono':  _tel.text.trim(),
        'programa':  _programaId,
      });
      if (mounted) {
        setState(() {
          _exito   = 'Estudiante #${resp['id']} registrado correctamente.';
          _cargando = false;
        });
        _limpiar();
        widget.onRegistrado?.call();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  void _limpiar() {
    _nombre.clear(); _doc.clear();
    _correo.clear(); _tel.clear();
    setState(() => _programaId = null);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registrar Estudiante',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _campo('Nombre Completo', _nombre,
                            validator: (v) => (v?.trim().length ?? 0) < 3
                                ? 'Minimo 3 caracteres' : null),
                        const SizedBox(height: 16),
                        _campo('Numero de Documento', _doc,
                            teclado: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (!RegExp(r'^\d{6,15}$').hasMatch(v))
                                return 'Solo numeros, entre 6 y 15 digitos';
                              return null;
                            }),
                        const SizedBox(height: 16),
                        _campo('Correo Electronico', _correo,
                            teclado: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(v))
                                return 'Formato de correo invalido';
                              return null;
                            }),
                        const SizedBox(height: 16),
                        _campo('Telefono', _tel,
                            teclado: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (!RegExp(r'^\d{7,15}$').hasMatch(v))
                                return 'Entre 7 y 15 digitos';
                              return null;
                            }),
                        const SizedBox(height: 16),

                        // Selector de programa
                        _cargandoProg
                            ? const LinearProgressIndicator()
                            : DropdownButtonFormField<int>(
                                value: _programaId,
                                decoration: const InputDecoration(
                                    labelText: 'Programa'),
                                items: _programas.map<DropdownMenuItem<int>>((p) {
                                  return DropdownMenuItem<int>(
                                    value: p['id'],
                                    child: Text(p['nombre'],
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _programaId = v),
                                validator: (_) => _programaId == null
                                    ? 'Seleccione un programa' : null,
                              ),
                        const SizedBox(height: 24),

                        // Mensajes
                        if (_error != null)
                          _mensaje(_error!, const Color(0xFFFEE2E2),
                              const Color(0xFFDC2626), Icons.error_outline),
                        if (_exito != null)
                          _mensaje(_exito!, const Color(0xFFDCFCE7),
                              const Color(0xFF16A34A), Icons.check_circle_outline),
                        const SizedBox(height: 8),

                        // Botones
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cargando ? null : _registrar,
                                child: _cargando
                                    ? const SizedBox(height: 20, width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white))
                                    : const Text('Registrar Estudiante',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: _limpiar,
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {TextInputType? teclado, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: teclado,
      decoration: InputDecoration(labelText: label),
      validator: validator ?? (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
    );
  }

  Widget _mensaje(String msg, Color bg, Color fg, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: TextStyle(color: fg, fontSize: 13))),
        ],
      ),
    );
  }
}
