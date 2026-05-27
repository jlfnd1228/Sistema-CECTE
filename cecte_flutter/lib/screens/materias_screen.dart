import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});
  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  List<dynamic> _programas     = [];
  int?          _programaSelec;
  List<dynamic> _materias      = [];
  bool          _cargando      = true;

  static const Color kPrimary = Color(0xFF0A6E7A);

  final List<Color> _colores = const [
    Color(0xFF0A6E7A), Color(0xFF1D4ED8),
    Color(0xFF7C3AED), Color(0xFFB45309), Color(0xFF059669),
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgramas();
  }

  Future<void> _cargarProgramas() async {
    final token = context.read<AuthService>().token;
    try {
      final data = await ApiService(token).get('programas/');
      final lista = data is List ? data : (data['results'] ?? []);
      if (mounted) {
        setState(() { _programas = lista; _cargando = false; });
        if (lista.isNotEmpty) {
          _programaSelec = lista[0]['id'];
          _cargarMaterias(_programaSelec!);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cargarMaterias(int programaId) async {
    setState(() => _cargando = true);
    final token = context.read<AuthService>().token;
    try {
      final data = await ApiService(token).get('materias/?programa=$programaId');
      final lista = data is List ? data : (data['results'] ?? []);
      if (mounted) setState(() { _materias = lista; _cargando = false; });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Agrupa materias por semestre usando el campo descripcion
  Map<String, List<dynamic>> _agruparPorSemestre() {
    final Map<String, List<dynamic>> grupos = {};
    for (final m in _materias) {
      final semestre = m['descripcion']?.toString().isNotEmpty == true
          ? m['descripcion'].toString()
          : 'Sin semestre';
      grupos.putIfAbsent(semestre, () => []).add(m);
    }
    // Ordenar: Semestre I, II, III
    final ordenados = <String, List<dynamic>>{};
    final claves = grupos.keys.toList()..sort((a, b) {
      final orden = ['Semestre I', 'Semestre II', 'Semestre III'];
      return orden.indexOf(a).compareTo(orden.indexOf(b));
    });
    for (final k in claves) ordenados[k] = grupos[k]!;
    return ordenados;
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _agruparPorSemestre();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Modulos por Programa',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          if (_programas.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButton<int>(
                  value: _programaSelec,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('Seleccione un programa'),
                  items: _programas.map<DropdownMenuItem<int>>((p) =>
                    DropdownMenuItem(
                      value: p['id'] as int,
                      child: Row(children: [
                        const Icon(Icons.school, size: 16, color: kPrimary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p['nombre'], overflow: TextOverflow.ellipsis)),
                      ]),
                    )
                  ).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _programaSelec = v);
                    _cargarMaterias(v);
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _materias.isEmpty
                ? const Center(child: Text('No hay modulos para este programa.',
                    style: TextStyle(color: Color(0xFF64748B))))
                : ListView(
                    children: grupos.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(entry.key,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 320,
                              childAspectRatio: 2.4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (_, i) {
                              final m = entry.value[i];
                              final color = _colores[m['id'] % _colores.length];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42, height: 42,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            m['codigo']?.toString().split('-').last ?? '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: color, fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(m['nombre'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color: Color(0xFF1E293B)),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 3),
                                            Row(children: [
                                              Text(m['codigo'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 10, color: Color(0xFF64748B))),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text('${m['creditos']} cred.',
                                                    style: TextStyle(
                                                        fontSize: 10, color: color,
                                                        fontWeight: FontWeight.w600)),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}