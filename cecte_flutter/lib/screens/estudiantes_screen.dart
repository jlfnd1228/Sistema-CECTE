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
  List<dynamic> _estudiantes  = [];
  List<dynamic> _filtrados    = [];
  List<dynamic> _programas    = [];
  bool   _loading         = true;
  String _filtroPrograma  = 'todos';
  final  _searchCtrl      = TextEditingController();

  static const Color kPrimary = Color(0xFF0A6E7A);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final token = context.read<AuthService>().token;
    final api   = ApiService(token);
    try {
      final dataE  = await api.get('estudiantes/');
      final dataP  = await api.get('programas/');
      final listaE = dataE is List ? dataE : (dataE['results'] ?? []);
      final listaP = dataP is List ? dataP : (dataP['results'] ?? []);
      if (mounted) setState(() {
        _estudiantes = listaE;
        _filtrados   = listaE;
        _programas   = listaP;
        _loading     = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filtrar(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtrados = _estudiantes.where((e) {
        final texto =
            (e['nombre'] ?? '').toString().toLowerCase().contains(lower) ||
            (e['documento'] ?? '').toString().toLowerCase().contains(lower) ||
            (e['programa_nombre'] ?? '').toString().toLowerCase().contains(lower);
        final prog = _filtroPrograma == 'todos' ||
            (e['programa_nombre'] ?? '') == _filtroPrograma;
        return texto && prog;
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
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm != true) return;
    final token = context.read<AuthService>().token;
    try {
      await ApiService(token).delete('estudiantes/$id/');
      await _cargar();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante eliminado'),
            backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editarPrograma(Map estudiante) async {
    int? programaSelec = estudiante['programa'];
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.school, color: kPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text('Asignar programa a ${estudiante['nombre']}',
                style: const TextStyle(fontSize: 16))),
          ]),
          content: SizedBox(
            width: 400,
            child: DropdownButtonFormField<int>(
              value: programaSelec,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Selecciona un programa'),
              items: _programas.map<DropdownMenuItem<int>>((p) =>
                DropdownMenuItem(
                  value: p['id'] as int,
                  child: Text(p['nombre'], overflow: TextOverflow.ellipsis))
              ).toList(),
              onChanged: (v) => setS(() => programaSelec = v),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (programaSelec == null) return;
                final token = context.read<AuthService>().token;
                try {
                  await ApiService(token).put(
                    'estudiantes/${estudiante['id']}/',
                    {
                      'nombre':    estudiante['nombre'],
                      'documento': estudiante['documento'],
                      'correo':    estudiante['correo'],
                      'telefono':  estudiante['telefono'] ?? '',
                      'programa':  programaSelec,
                    },
                  );
                  Navigator.pop(ctx);
                  await _cargar();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Programa asignado correctamente'),
                        backgroundColor: kPrimary));
                } catch (e) {
                  Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verInscripciones(Map estudiante) async {
    final token = context.read<AuthService>().token;
    List<dynamic> inscripciones = [];
    bool cargando = true;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          if (cargando) {
            ApiService(token)
              .get('inscripciones/?estudiante=${estudiante['id']}')
              .then((data) {
                setS(() {
                  inscripciones = data is List ? data : (data['results'] ?? []);
                  cargando = false;
                });
              })
              .catchError((_) => setS(() => cargando = false));
          }
          return AlertDialog(
            title: Row(children: [
              const Icon(Icons.assignment, color: kPrimary),
              const SizedBox(width: 8),
              Expanded(child: Text('Inscripciones – ${estudiante['nombre']}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis)),
            ]),
            content: SizedBox(
              width: 540,
              child: cargando
                ? const SizedBox(height: 80,
                    child: Center(child: CircularProgressIndicator()))
                : inscripciones.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Este estudiante no tiene inscripciones.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: inscripciones.length,
                      itemBuilder: (_, i) {
                        final ins = Map<String, dynamic>.from(inscripciones[i]);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: kPrimary.withOpacity(0.15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.menu_book,
                                      color: kPrimary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(ins['materia_nombre'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))),
                                ]),
                                const SizedBox(height: 4),
                                Text(ins['programa_nombre'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF64748B))),
                                const Divider(height: 16),
                                // Estado
                                Row(children: [
                                  const Text('Estado: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: ins['estado'],
                                    isDense: true,
                                    underline: Container(height: 1, color: kPrimary),
                                    items: ['activa', 'aprobada', 'retirada']
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Row(children: [
                                                Icon(
                                                  s == 'aprobada'
                                                    ? Icons.check_circle
                                                    : s == 'retirada'
                                                      ? Icons.cancel
                                                      : Icons.hourglass_empty,
                                                  size: 14,
                                                  color: s == 'aprobada'
                                                    ? Colors.green
                                                    : s == 'retirada'
                                                      ? Colors.red
                                                      : kPrimary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(s, style: const TextStyle(fontSize: 13)),
                                              ]),
                                            ))
                                        .toList(),
                                    onChanged: (nuevoEstado) async {
                                      if (nuevoEstado == null) return;
                                      try {
                                        await ApiService(token).put(
                                          'inscripciones/${ins['id']}/',
                                          {
                                            'estudiante': ins['estudiante'],
                                            'materia':    ins['materia'],
                                            'estado':     nuevoEstado,
                                            'nota_final': ins['nota_final'],
                                          },
                                        );
                                        setS(() => inscripciones[i]['estado'] = nuevoEstado);
                                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Estado actualizado'),
                                              backgroundColor: kPrimary));
                                      } catch (e) {
                                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')));
                                      }
                                    },
                                  ),
                                ]),
                                const SizedBox(height: 10),
                                // Nota final
                                Row(children: [
                                  const Text('Nota final: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _NotaField(
                                      key: ValueKey(ins['id']),
                                      notaInicial: ins['nota_final']?.toString() ?? '',
                                      onGuardar: (nota) async {
                                        await ApiService(token).put(
                                          'inscripciones/${ins['id']}/',
                                          {
                                            'estudiante': ins['estudiante'],
                                            'materia':    ins['materia'],
                                            'estado':     ins['estado'],
                                            'nota_final': nota.isEmpty
                                                ? null
                                                : double.tryParse(nota),
                                          },
                                        );
                                        setS(() => inscripciones[i]['nota_final'] =
                                            nota.isEmpty ? null : nota);
                                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Nota guardada'),
                                              backgroundColor: kPrimary));
                                      },
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar')),
            ],
          );
        },
      ),
    );
  }

  int get _totalSinPrograma =>
      _estudiantes.where((e) => e['programa'] == null).length;
  int get _totalConPrograma =>
      _estudiantes.where((e) => e['programa'] != null).length;

  @override
  Widget build(BuildContext context) {
    final esAdmin = context.watch<AuthService>().esAdmin;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Gestión de Estudiantes',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            const Spacer(),
            IconButton(tooltip: 'Actualizar', onPressed: _cargar,
                icon: const Icon(Icons.refresh)),
          ]),
          const SizedBox(height: 20),
          // Tarjetas resumen
          Row(children: [
            Expanded(child: _cardResumen('Total estudiantes',
                '${_estudiantes.length}', Icons.people, kPrimary)),
            const SizedBox(width: 12),
            Expanded(child: _cardResumen('Con programa',
                '$_totalConPrograma', Icons.school, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _cardResumen('Sin programa',
                '$_totalSinPrograma', Icons.warning_amber, Colors.orange)),
          ]),
          const SizedBox(height: 20),
          // Buscador + filtro
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filtrar,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, documento o programa...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String>(
                value: _filtroPrograma,
                decoration: const InputDecoration(labelText: 'Filtrar programa'),
                items: [
                  const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                  ..._programas.map((p) => DropdownMenuItem<String>(
                    value: p['nombre'],
                    child: Text(p['nombre'], overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) {
                  _filtroPrograma = v ?? 'todos';
                  _filtrar(_searchCtrl.text);
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtrados.isEmpty
                ? const Center(child: Text('No hay estudiantes registrados'))
                : Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFF1F5F9)),
                        columns: [
                          const DataColumn(label: Text('Nombre')),
                          const DataColumn(label: Text('Documento')),
                          const DataColumn(label: Text('Correo')),
                          const DataColumn(label: Text('Programa')),
                          if (esAdmin)
                            const DataColumn(label: Text('Acciones')),
                        ],
                        rows: _filtrados.map((e) => DataRow(cells: [
                          DataCell(Text(e['nombre'] ?? '')),
                          DataCell(Text(e['documento'] ?? '')),
                          DataCell(Text(e['correo'] ?? '')),
                          DataCell(Row(children: [
                            Text(
                              e['programa_nombre'] ?? 'Sin programa',
                              style: TextStyle(
                                color: e['programa'] == null
                                    ? Colors.orange : Colors.black87),
                            ),
                            if (e['programa'] == null) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.warning_amber,
                                  color: Colors.orange, size: 18),
                            ],
                          ])),
                          if (esAdmin) DataCell(Row(children: [
                            IconButton(
                              tooltip: 'Ver inscripciones y notas',
                              icon: const Icon(Icons.list_alt, color: kPrimary),
                              onPressed: () => _verInscripciones(e),
                            ),
                            IconButton(
                              tooltip: 'Asignar programa',
                              icon: const Icon(Icons.school, color: Colors.blue),
                              onPressed: () => _editarPrograma(e),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminar(e['id'], e['nombre']),
                            ),
                          ])),
                        ])).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cardResumen(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(blurRadius: 10,
            color: Color.fromARGB(20, 0, 0, 0))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icono, color: color),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: const TextStyle(
              color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22)),
        ]),
      ]),
    );
  }
}

// ── Widget independiente para el campo de nota ──────────────────────────
class _NotaField extends StatefulWidget {
  final String notaInicial;
  final Future<void> Function(String) onGuardar;
  const _NotaField({super.key, required this.notaInicial, required this.onGuardar});
  @override
  State<_NotaField> createState() => _NotaFieldState();
}

class _NotaFieldState extends State<_NotaField> {
  late TextEditingController _ctrl;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.notaInicial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 90,
        child: TextField(
          controller: _ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: '0.0 – 5.0',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ),
      ),
      const SizedBox(width: 8),
      _guardando
        ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A6E7A),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            onPressed: () async {
              setState(() => _guardando = true);
              try {
                await widget.onGuardar(_ctrl.text.trim());
              } catch (_) {}
              if (mounted) setState(() => _guardando = false);
            },
            child: const Text('Guardar',
                style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
    ]);
  }
}