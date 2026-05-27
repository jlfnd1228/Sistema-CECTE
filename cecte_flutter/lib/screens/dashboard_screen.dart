import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'estudiantes_screen.dart';
import 'registro_screen.dart';
import 'materias_screen.dart';
import 'estudiante_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _seccion = 0;
  Map<String, dynamic> _stats = {};
  bool _cargando = true;

  static const Color kPrimary   = Color(0xFF0A6E7A);
  static const Color kSidebarBg = Color(0xFF042F35);
  static const Color kBackground = Color(0xFFF4F7FA);

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    if (auth.esAdmin || auth.usuario?['rol'] == 'usuario') {
      _cargarStats();
    }
  }

  Future<void> _cargarStats() async {
    final token = context.read<AuthService>().token;
    try {
      final data = await ApiService(token).get('dashboard/');
      if (mounted) setState(() { _stats = data; _cargando = false; });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();

    // Si es estudiante, mostrar directamente su pantalla
    if (auth.esEstudiante) {
      return const EstudianteHomeScreen();
    }

    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: kBackground,
      drawer: isWide ? null : _buildSidebar(auth),
      body: Row(
        children: [
          if (isWide) _buildSidebar(auth),
          Expanded(child: _buildContent(auth)),
        ],
      ),
    );
  }

  Widget _buildSidebar(AuthService auth) {
    final items = [
      {'icon': Icons.dashboard,  'label': 'Dashboard'},
      {'icon': Icons.people,     'label': 'Estudiantes'},
      if (auth.esAdmin) {'icon': Icons.person_add, 'label': 'Registro'},
      {'icon': Icons.menu_book,  'label': 'Materias'},
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
                    style: TextStyle(color: Colors.white,
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(auth.esAdmin ? 'Administrador' : 'Usuario',
                    style: const TextStyle(
                        color: Color(0xFFD9F2F6), fontSize: 12)),
              ],
            ),
          ),
          ...List.generate(items.length, (i) {
            final active = _seccion == i;
            return GestureDetector(
              onTap: () {
                setState(() => _seccion = i);
                if (i == 0) _cargarStats();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: active ? kPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(items[i]['icon'] as IconData,
                        color: active ? Colors.white : const Color(0xFFB0D4DA),
                        size: 20),
                    const SizedBox(width: 12),
                    Text(items[i]['label'] as String,
                        style: TextStyle(
                          color: active ? Colors.white : const Color(0xFFB0D4DA),
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        )),
                  ],
                ),
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
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text('Cerrar Sesion',
                      style: TextStyle(color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AuthService auth) {
    final hasRegistro = auth.esAdmin;
    switch (_seccion) {
      case 0: return _buildDashboard(auth);
      case 1: return const EstudiantesScreen();
      case 2: return hasRegistro
          ? RegistroScreen(onRegistrado: _cargarStats)
          : const MateriasScreen();
      case 3: return const MateriasScreen();
      default: return _buildDashboard(auth);
    }
  }

  Widget _buildDashboard(AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bienvenido, ${auth.nombreUsuario}',
                        style: const TextStyle(fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B))),
                    Text(auth.esAdmin ? 'Panel de Administrador' : 'Panel de Usuario',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Text(_hoyFormateado(),
                  style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 24),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 16, runSpacing: 16,
              children: [
                _statCard('Estudiantes', '${_stats['total_estudiantes'] ?? 0}',
                    Icons.people, kPrimary),
                _statCard('Programas', '${_stats['total_programas'] ?? 0}',
                    Icons.school, const Color(0xFF1D4ED8)),
                _statCard('Materias', '${_stats['total_materias'] ?? 0}',
                    Icons.menu_book, const Color(0xFF7C3AED)),
                _statCard('Inscripciones', '${_stats['total_inscripciones'] ?? 0}',
                    Icons.assignment, const Color(0xFFB45309)),
              ],
            ),
          const SizedBox(height: 28),
          if (!_cargando && _stats['por_programa'] != null) ...[
            const Text('Estudiantes por Programa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    for (final p in (_stats['por_programa'] as List))
                      _programaBar(
                        p['nombre'] ?? '',
                        (p['cantidad'] ?? 0).toDouble(),
                        (_stats['total_estudiantes'] ?? 1).toDouble(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String titulo, String valor, IconData icon, Color color) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 14),
              Text(titulo,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text(valor,
                  style: TextStyle(fontSize: 30,
                      fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _programaBar(String nombre, double cantidad, double total) {
    final pct = total > 0 ? cantidad / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(nombre,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
              Text('${cantidad.toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF0A6E7A)),
            ),
          ),
        ],
      ),
    );
  }

  String _hoyFormateado() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }
}