import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class EstudianteHomeScreen extends StatefulWidget {
  const EstudianteHomeScreen({super.key});
  @override
  State<EstudianteHomeScreen> createState() => _EstudianteHomeScreenState();
}

class _EstudianteHomeScreenState extends State<EstudianteHomeScreen> {
  static const Color kPrimary   = Color(0xFF0A6E7A);
  static const Color kSidebarBg = Color(0xFF042F35);

  int _seccion = 0;
  Map<String, dynamic>? _perfil;
  List<dynamic> _misInscripciones    = [];
  List<dynamic> _materiasDisponibles = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final token = context.read<AuthService>().token;
    final api   = ApiService(token);
    try {
      final perfil        = await api.get('estudiante/perfil/');
      final inscripciones = await api.get('estudiante/materias/');

      final programaId = perfil is Map ? perfil['programa'] : null;
      List<dynamic> materias = [];
      if (programaId != null) {
        final data = await api.get('materias/?programa=$programaId');
        materias = data is List ? data : (data['results'] ?? []);
      }

      if (mounted) setState(() {
        _perfil              = perfil is Map ? Map<String, dynamic>.from(perfil) : null;
        _misInscripciones    = inscripciones is List ? inscripciones : [];
        _materiasDisponibles = materias;
        _cargando            = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _inscribirse(int materiaId) async {
    final token = context.read<AuthService>().token;
    try {
      await ApiService(token).post('estudiante/inscribirse/', {'materia_id': materiaId});
      await _cargarDatos();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscripcion exitosa'),
            backgroundColor: kPrimary));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _cancelarInscripcion(int inscripcionId, String nombreMateria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar inscripcion'),
        content: Text('¿Deseas cancelar la inscripcion en "$nombreMateria"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Si, cancelar')),
        ],
      ),
    );
    if (confirm != true) return;
    final token = context.read<AuthService>().token;
    try {
      await ApiService(token).delete('inscripciones/$inscripcionId/');
      await _cargarDatos();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscripcion cancelada'),
            backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    }
  }

  void _confirmarInscripcion(int materiaId, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar inscripcion'),
        content: Text('¿Deseas inscribirte en "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _inscribirse(materiaId); },
            child: const Text('Confirmar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      drawer: isWide ? null : _buildSidebar(auth),
      appBar: isWide ? null : AppBar(
        backgroundColor: kSidebarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('CECTE', style: TextStyle(color: Colors.white)),
      ),
      body: Row(
        children: [
          if (isWide) _buildSidebar(auth),
          Expanded(
            child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _seccion == 0 ? _buildMiPerfil() : _buildMisMaterias(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AuthService auth) {
    final items = [
      {'icon': Icons.person,    'label': 'Mi Perfil'},
      {'icon': Icons.menu_book, 'label': 'Mis Materias'},
    ];
    return Container(
      width: 240,
      color: kSidebarBg,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('CECTE',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(auth.nombreUsuario,
                    style: const TextStyle(color: Color(0xFFD9F2F6),
                        fontSize: 12)),
                const Text('Estudiante',
                    style: TextStyle(color: Color(0xFFD9F2F6), fontSize: 11)),
              ],
            ),
          ),
          ...List.generate(items.length, (i) {
            final active = _seccion == i;
            return GestureDetector(
              onTap: () => setState(() => _seccion = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: active ? kPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(items[i]['icon'] as IconData,
                      color: active ? Colors.white : const Color(0xFFB0D4DA),
                      size: 20),
                  const SizedBox(width: 12),
                  Text(items[i]['label'] as String,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFFB0D4DA),
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      )),
                ]),
              ),
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => auth.logout(),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.logout, color: Colors.redAccent, size: 20),
                SizedBox(width: 12),
                Text('Cerrar Sesion',
                    style: TextStyle(color: Colors.redAccent,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiPerfil() {
    if (_perfil == null) {
      return const Center(child: Text('No se encontro perfil.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mi Perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: kPrimary,
                    child: Text(
                      (_perfil!['nombre'] as String? ?? 'E')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_perfil!['nombre'] ?? '',
                      style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Estudiante',
                        style: TextStyle(color: kPrimary,
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                  _infoRow(Icons.badge_outlined, 'Documento',
                      _perfil!['documento'] ?? ''),
                  _infoRow(Icons.email_outlined, 'Correo',
                      _perfil!['correo'] ?? ''),
                  _infoRow(Icons.phone_outlined, 'Telefono',
                      _perfil!['telefono']?.toString().isNotEmpty == true
                          ? _perfil!['telefono'] : 'No registrado'),
                  _infoRow(Icons.school_outlined, 'Programa',
                      _perfil!['programa_nombre'] ?? 'Sin programa asignado'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statCard('Inscritas', '${_misInscripciones.length}',
                          kPrimary),
                      const SizedBox(width: 16),
                      _statCard('Disponibles',
                          '${_materiasDisponibles.length - _misInscripciones.length}',
                          const Color(0xFF1D4ED8)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(valor, style: TextStyle(fontSize: 28,
              fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, color: kPrimary, size: 20),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        Expanded(child: Text(valor, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _buildMisMaterias() {
    final idsInscritos = _misInscripciones
        .map((i) => i['materia'] as int)
        .toSet();
    final disponibles = _materiasDisponibles
        .where((m) => !idsInscritos.contains(m['id']))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mis Materias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('${_misInscripciones.length} inscritas · '
              '${disponibles.length} disponibles',
              style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          if (_misInscripciones.isNotEmpty) ...[
            _seccionHeader('Mis inscripciones', kPrimary),
            const SizedBox(height: 10),
            ..._misInscripciones.map((i) => _materiaCard(
              nombre:      i['materia_nombre'] ?? '',
              programa:    i['programa_nombre'] ?? '',
              estado:      i['estado'] ?? '',
              inscrito:    true,
              onCancelar:  () => _cancelarInscripcion(
                  i['id'] as int, i['materia_nombre'] ?? ''),
            )),
            const SizedBox(height: 20),
          ],
          if (disponibles.isEmpty && _misInscripciones.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.school_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No tienes materias disponibles.',
                      style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  const Text(
                      'El administrador debe asignarte un programa primero.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                ],
              ),
            ),
          ] else if (disponibles.isNotEmpty) ...[
            _seccionHeader('Disponibles para inscribirse',
                const Color(0xFF64748B)),
            const SizedBox(height: 10),
            ...disponibles.map((m) => _materiaCard(
              nombre:         m['nombre'] ?? '',
              programa:       m['programa_nombre'] ?? '',
              estado:         'disponible',
              inscrito:       false,
              onInscribirse:  () => _confirmarInscripcion(
                  m['id'] as int, m['nombre'] ?? ''),
            )),
          ],
        ],
      ),
    );
  }

  Widget _seccionHeader(String titulo, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(titulo,
          style: TextStyle(fontWeight: FontWeight.bold,
              color: color, fontSize: 14)),
    );
  }

  Widget _materiaCard({
    required String nombre,
    required String programa,
    required String estado,
    required bool inscrito,
    VoidCallback? onCancelar,
    VoidCallback? onInscribirse,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: inscrito
              ? kPrimary.withOpacity(0.15)
              : const Color(0xFF64748B).withOpacity(0.1),
          child: Icon(
            inscrito ? Icons.check_circle : Icons.add_circle_outline,
            color: inscrito ? kPrimary : const Color(0xFF64748B),
          ),
        ),
        title: Text(nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(programa,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF64748B))),
        trailing: inscrito
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(estado,
                      style: const TextStyle(color: kPrimary,
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  tooltip: 'Cancelar inscripcion',
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.red, size: 20),
                  onPressed: onCancelar,
                ),
              ],
            )
          : ElevatedButton(
              onPressed: onInscribirse,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
              ),
              child: const Text('Inscribirse',
                  style: TextStyle(fontSize: 12)),
            ),
      ),
    );
  }
}