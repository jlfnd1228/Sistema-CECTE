import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';

class EstudiantesScreen extends StatefulWidget {
  const EstudiantesScreen({super.key});

  @override
  State<EstudiantesScreen> createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {
  List<dynamic> _estudiantes = [];
  List<dynamic> _filtrados = [];
  List<dynamic> _programas = [];

  bool _loading = true;

  final _searchCtrl = TextEditingController();

  String _filtroPrograma = 'todos';

  static const Color kPrimary = Color(0xFF0A6E7A);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);

    final token = context.read<AuthService>().token;
    final api = ApiService(token);

    try {
      final dataE = await api.get('estudiantes/');
      final dataP = await api.get('programas/');

      final listaE = dataE is List ? dataE : (dataE['results'] ?? []);
      final listaP = dataP is List ? dataP : (dataP['results'] ?? []);

      if (mounted) {
        setState(() {
          _estudiantes = listaE;
          _filtrados = listaE;
          _programas = listaP;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando estudiantes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrar(String q) {
    final lower = q.toLowerCase();

    setState(() {
      _filtrados = _estudiantes.where((e) {
        final coincideTexto =
            (e['nombre'] ?? '')
                .toString()
                .toLowerCase()
                .contains(lower) ||
            (e['documento'] ?? '')
                .toString()
                .toLowerCase()
                .contains(lower) ||
            (e['programa_nombre'] ?? '')
                .toString()
                .toLowerCase()
                .contains(lower);

        final coincidePrograma =
            _filtroPrograma == 'todos' ||
            e['programa_nombre'] == _filtroPrograma;

        return coincideTexto && coincidePrograma;
      }).toList();
    });
  }

  Future<void> _eliminar(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text('¿Seguro que deseas eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = context.read<AuthService>().token;

    try {
      await ApiService(token).delete('estudiantes/$id/');

      await _cargar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estudiante eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  int get _totalSinPrograma {
    return _estudiantes.where((e) => e['programa'] == null).length;
  }

  int get _totalConPrograma {
    return _estudiantes.where((e) => e['programa'] != null).length;
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = context.watch<AuthService>().esAdmin;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Gestión de Estudiantes',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: _cargar,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _cardResumen(
                  'Total estudiantes',
                  '${_estudiantes.length}',
                  Icons.people,
                  kPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cardResumen(
                  'Con programa',
                  '$_totalConPrograma',
                  Icons.school,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cardResumen(
                  'Sin programa',
                  '$_totalSinPrograma',
                  Icons.warning_amber,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _filtrar,
                  decoration: const InputDecoration(
                    hintText:
                        'Buscar por nombre, documento o programa...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  value: _filtroPrograma,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar programa',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'todos',
                      child: Text('Todos'),
                    ),
                    ..._programas.map(
                      (p) => DropdownMenuItem<String>(
                        value: p['nombre'],
                        child: Text(p['nombre']),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    _filtroPrograma = v ?? 'todos';
                    _filtrar(_searchCtrl.text);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filtrados.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay estudiantes registrados',
                        ),
                      )
                    : Card(
                        elevation: 2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(
                              const Color(0xFFF1F5F9),
                            ),
                            columns: [
                              const DataColumn(
                                label: Text('Nombre'),
                              ),
                              const DataColumn(
                                label: Text('Documento'),
                              ),
                              const DataColumn(
                                label: Text('Correo'),
                              ),
                              const DataColumn(
                                label: Text('Programa'),
                              ),
                              if (esAdmin)
                                const DataColumn(
                                  label: Text('Acciones'),
                                ),
                            ],
                            rows: _filtrados.map((e) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(e['nombre'] ?? ''),
                                  ),
                                  DataCell(
                                    Text(e['documento'] ?? ''),
                                  ),
                                  DataCell(
                                    Text(e['correo'] ?? ''),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(
                                          e['programa_nombre'] ??
                                              'Sin programa',
                                          style: TextStyle(
                                            color:
                                                e['programa'] == null
                                                    ? Colors.orange
                                                    : Colors.black87,
                                          ),
                                        ),
                                        if (e['programa'] == null)
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(
                                              left: 6,
                                            ),
                                            child: Icon(
                                              Icons.warning_amber,
                                              color: Colors.orange,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (esAdmin)
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Eliminar',
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _eliminar(
                                              e['id'],
                                              e['nombre'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _cardResumen(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color.fromARGB(20, 0, 0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}