/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../../../services/nanda_service.dart';

// Historial
import '../../../models/paes_historial.dart';
import '../../../services/paes_historial_service.dart';

class PaesDiagnosticoScreen extends StatefulWidget {
  const PaesDiagnosticoScreen({super.key});

  @override
  State<PaesDiagnosticoScreen> createState() => _PaesDiagnosticoScreenState();
}

class _PaesDiagnosticoScreenState extends State<PaesDiagnosticoScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Color _iconGrey = Color.fromARGB(200, 255, 255, 255);

  // ───── Diagnóstico NANDA ─────
  String tipoDiagnostico = 'Real';
  String prioridad = 'Alta';

  final TextEditingController nandaCodigoCtrl = TextEditingController();
  final TextEditingController nandaEtiquetaCtrl = TextEditingController();
  final TextEditingController definicionCtrl = TextEditingController();
  final TextEditingController etiologiaCtrl = TextEditingController();
  final TextEditingController signosCtrl = TextEditingController();
  final TextEditingController factoresRiesgoCtrl = TextEditingController();
  final TextEditingController poblacionRiesgoCtrl = TextEditingController();
  final TextEditingController condicionesAsociadasCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  // ───── NUEVOS: Dominio / Clase ─────
  final TextEditingController dominioCtrl = TextEditingController();
  final TextEditingController claseCtrl = TextEditingController();

  List<Map<String, dynamic>> resultadosNanda = [];
  final List<String> problemasEnfermeria = [];

  bool _searchingNanda = false; // evita llamadas solapadas

  /*──────────────────── GUARDAR DIAGNÓSTICO EN HISTORIAL ────────────────────*/
  void _guardarDiagnostico() {
    final buffer = StringBuffer();

    buffer.writeln('Diagnóstico NANDA-I:');
    buffer.writeln('Código: ${nandaCodigoCtrl.text}');
    buffer.writeln('Etiqueta: ${nandaEtiquetaCtrl.text}');
    buffer.writeln('Dominio: ${dominioCtrl.text}');
    buffer.writeln('Clase: ${claseCtrl.text}');
    buffer.writeln('Definición: ${definicionCtrl.text}');
    buffer.writeln('Etiología: ${etiologiaCtrl.text}');
    if (tipoDiagnostico == 'Real') {
      buffer.writeln('Signos y síntomas: ${signosCtrl.text}');
    } else {
      buffer.writeln('Factores de riesgo: ${factoresRiesgoCtrl.text}');
      buffer.writeln('Población en riesgo: ${poblacionRiesgoCtrl.text}');
    }
    buffer.writeln('Condiciones asociadas: ${condicionesAsociadasCtrl.text}');
    buffer.writeln('Problemas de enfermería:');
    for (var p in problemasEnfermeria) {
      buffer.writeln('- $p');
    }

    // Guardamos en historial
    PaesHistorialService.agregar(
      PaesHistorialItem(
        etapa: PaesEtapa.diagnostico,
        contenido: buffer.toString(),
        fecha: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnóstico guardado en historial')),
    );

    // Limpiar campos y resultados para agregar otro diagnóstico
    setState(() {
      nandaCodigoCtrl.clear();
      nandaEtiquetaCtrl.clear();
      definicionCtrl.clear();
      etiologiaCtrl.clear();
      signosCtrl.clear();
      factoresRiesgoCtrl.clear();
      poblacionRiesgoCtrl.clear();
      condicionesAsociadasCtrl.clear();
      dominioCtrl.clear();
      claseCtrl.clear();
      searchCtrl.clear();
      resultadosNanda = [];
      problemasEnfermeria.clear();
      tipoDiagnostico = 'Real';
      prioridad = 'Alta';
    });
  }

  /*──────────────────── SUGERENCIA INTELIGENTE DE PROBLEMAS ────────────────────*/
  void _sugerirProblema(String etiqueta, String definicion) {
    final keywords = [
      'dolor',
      'ansiedad',
      'movilidad',
      'alimentación',
      'respiración',
      'fatiga',
      'estrés',
      'riesgo',
      'deficiencia',
      'infección',
      'integridad'
    ];

    final texto = ('$etiqueta $definicion').toLowerCase();
    final sugerencias = <String>{};

    for (var key in keywords) {
      if (texto.contains(key)) {
        sugerencias.add('Problema de enfermería relacionado con "$key"');
      }
    }

    // Si no se encuentra ninguna palabra clave, agregamos una genérica
    if (sugerencias.isEmpty) {
      sugerencias.add('Problema de enfermería relacionado con "$etiqueta"');
    }

    setState(() {
      for (var p in sugerencias) {
        if (!problemasEnfermeria.contains(p)) {
          problemasEnfermeria.add(p);
        }
      }
    });
  }

  /*──────────────────── MOSTRAR HISTORIAL ────────────────────*/
  void _verHistorial() {
    final historial = PaesHistorialService.obtenerPorEtapa(PaesEtapa.diagnostico);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Historial de Diagnósticos'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay diagnósticos guardados.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (_, index) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Diagnóstico ${index + 1}'),
                      subtitle: Text(historial[index].contenido),
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // utilidades para normalizar / extraer código desde la query
  // ======================================================================
  String _normalize(String s) => s.trim().toLowerCase();

  String? _extractDigits(String q) {
    final reg = RegExp(r'(\d{2,5})');
    final m = reg.firstMatch(q.replaceAll(RegExp(r'[^0-9]'), ' '));
    if (m == null) return null;
    return m.group(1);
  }

  bool _exactMatchWithQuery(Map<String, dynamic> item, String query) {
    final q = _normalize(query);
    final code = (item['codigo'] ?? '').toString().toLowerCase();
    final label = (item['etiqueta'] ?? '').toString().toLowerCase();

    if (q == label) return true;

    final extracted = _extractDigits(query);
    if (extracted != null) {
      final intExtracted = int.tryParse(extracted);
      final intCode = int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), ''));
      if (intExtracted != null && intCode != null && intExtracted == intCode) {
        return true;
      }
      if (extracted == code) return true;
    }

    if (q == code) return true;

    return false;
  }

  // ======================================================================
  // Función robusta para buscar NANDA (mejorada) - CORREGIDA (await)
  // ======================================================================
  Future<void> _searchNanda(String query) async {
    if (_searchingNanda) return;
    _searchingNanda = true;

    try {
      // Maneja tanto retorno síncrono como Future de manera segura:
      final resRaw = await Future.value(NandaService.search(query));
      final res = List<Map<String, dynamic>>.from(resRaw);

      if (!mounted) return;

      setState(() {
        resultadosNanda = res;
      });

      // Autoselección: si solo hay 1 resultado y coincide exactamente con la query
      if (res.length == 1 && _exactMatchWithQuery(res[0], query)) {
        final n = res[0];

        nandaCodigoCtrl.text = n['codigo'] ?? '';
        nandaEtiquetaCtrl.text = n['etiqueta'] ?? '';
        definicionCtrl.text = n['definicion'] ?? '';
        // Rellenar Dominio/Clase si existen en el JSON
        dominioCtrl.text = n['dominio'] ?? '';
        claseCtrl.text = n['clase'] ?? '';

        // Limpiar lista y búsqueda al seleccionar
        setState(() {
          resultadosNanda = [];
          searchCtrl.clear();
        });

        // Sugerir problema automáticamente según palabras clave
        _sugerirProblema(n['etiqueta'] ?? '', n['definicion'] ?? '');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        resultadosNanda = [];
      });
    } finally {
      _searchingNanda = false;
    }
  }

  // ==========================================================
  // FUNCIONES PARA ABRIR EL PDF DEL CATÁLOGO (NANDA) Y NAVEGAR
  // ==========================================================
  // Copia el asset PDF a un archivo temporal y devuelve la ruta
  Future<String> _copyAssetPdfToTemp(String assetPath, String filename) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  // Abre un viewer que permite desplazarse por todo el PDF, iniciando en la página solicitada
  Future<void> _openPdfViewer({
    required String assetPath,
    required String title,
    int initialPage = 1,
  }) async {
    try {
      final path = await _copyAssetPdfToTemp(assetPath, title.replaceAll(' ', '_') + '.pdf');

      // Producimos un Future<PdfDocument> y lo pasamos al viewer; el viewer
      // se encargará de crear el controlador adecuado según la plataforma.
      final Future<PdfDocument> docFuture = PdfDocument.openFile(path);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PdfViewerScreen(
            documentFuture: docFuture,
            title: title,
            initialPage: initialPage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir PDF: $e')),
      );
    }
  }

  @override
  void dispose() {
    nandaCodigoCtrl.dispose();
    nandaEtiquetaCtrl.dispose();
    definicionCtrl.dispose();
    etiologiaCtrl.dispose();
    signosCtrl.dispose();
    factoresRiesgoCtrl.dispose();
    poblacionRiesgoCtrl.dispose();
    condicionesAsociadasCtrl.dispose();
    searchCtrl.dispose();

    // Dispose nuevos
    dominioCtrl.dispose();
    claseCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnóstico de Enfermería',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
          ),
        ),        backgroundColor: const Color(0xFF660033),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            color: _iconGrey,
            tooltip: 'Abrir libro NANDA',
            onPressed: () {
              // Abre el libro completo desde la primera página
              _openPdfViewer(
                assetPath: 'assets/data/nanda.pdf',
                title: 'NANDA-I 2026',
                initialPage: 1,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            color: _iconGrey,
            tooltip: 'Ver historial',
            onPressed: _verHistorial,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Clasificación del diagnóstico'),
              _row([_dropdownTipo(), _dropdownPrioridad()]),

              _sectionTitle('Buscar diagnóstico NANDA 2026'),
              TextFormField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar por código o etiqueta',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // llamada robusta:
                  _searchNanda(value);
                },
              ),
              const SizedBox(height: 10),

              if (resultadosNanda.isNotEmpty)
                Column(
                  children: resultadosNanda.map((n) {
                    final pageRaw = n['pagina_pdf'] ?? n['pagina'] ?? 1;
                    final page = int.tryParse(pageRaw.toString()) ?? 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('${n['codigo']} – ${n['etiqueta']}'),
                        subtitle: Text(
                          '${n['dominio'] ?? '-'} • ${n['clase'] ?? '-'}\nPágina NANDA: $page',
                        ),
                        // seleccionar con tap
                        onTap: () {
                          nandaCodigoCtrl.text = n['codigo'] ?? '';
                          nandaEtiquetaCtrl.text = n['etiqueta'] ?? '';
                          definicionCtrl.text = n['definicion'] ?? '';
                          // Rellenar Dominio/Clase si vienen en el JSON
                          dominioCtrl.text = n['dominio'] ?? '';
                          claseCtrl.text = n['clase'] ?? '';

                          // Limpiar lista y búsqueda al seleccionar
                          setState(() {
                            resultadosNanda = [];
                            searchCtrl.clear();
                          });

                          // Sugerir problema automáticamente según palabras clave
                          _sugerirProblema(n['etiqueta'] ?? '', n['definicion'] ?? '');
                        },
                        onLongPress: () {
                          // Abrir el PDF de NANDA en la página correspondiente
                          _openPdfViewer(
                            assetPath: 'assets/data/nanda.pdf',
                            title: 'NANDA-I 2026',
                            initialPage: page,
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),

              _sectionTitle('Diagnóstico NANDA-I'),
              _text(nandaCodigoCtrl, 'Código NANDA (ej. 00032)'),
              _text(nandaEtiquetaCtrl, 'Etiqueta diagnóstica'),
              // Mostrar Dominio y Clase
              _text(dominioCtrl, 'Dominio'),
              _text(claseCtrl, 'Clase'),
              _textArea(definicionCtrl, 'Definición'),
              _textArea(etiologiaCtrl, 'Etiología (relacionado con…)'),

              if (tipoDiagnostico == 'Real') _textArea(signosCtrl, 'Signos y síntomas (manifestado por…)'),

              if (tipoDiagnostico != 'Real') ...[
                _textArea(factoresRiesgoCtrl, 'Factores de riesgo'),
                _textArea(poblacionRiesgoCtrl, 'Población en riesgo'),
              ],

              _textArea(condicionesAsociadasCtrl, 'Condiciones asociadas'),

              _sectionTitle('Problemas de enfermería'),
              _addItem(
                label: 'Agregar problema',
                onAdd: (value) {
                  setState(() => problemasEnfermeria.add(value));
                },
              ),
              _list(problemasEnfermeria),

              const SizedBox(height: 30),

              // ---------- BOTÓN GUARDAR ----------
              SizedBox(
                width: double.infinity, // ocupa todo el ancho disponible (más largo)
                child: ElevatedButton.icon(
                  onPressed: _guardarDiagnostico,
                  icon: const Icon(
                    Icons.save,
                    color: Color(0xFF660033), // ícono en color institucional
                  ),
                  label: const Text(
                    'Guardar planificación',
                    style: TextStyle(
                      color: Color(0xFF660033),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F0E6), // crema
                    padding: const EdgeInsets.symmetric(
                      vertical: 16, // un poco más alto
                      horizontal: 22,
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  /*──────────────────── WIDGETS ────────────────────*/

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _text(TextEditingController c, String label) => TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
      );

  Widget _textArea(TextEditingController c, String label) => TextFormField(
        controller: c,
        maxLines: 3,
        decoration: InputDecoration(labelText: label),
      );

  Widget _row(List<Widget> children) => Row(
        children: children
            .map(
              (e) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: e,
                ),
              ),
            )
            .toList(),
      );

  Widget _dropdownTipo() => DropdownButtonFormField<String>(
        initialValue: tipoDiagnostico,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'Real', child: Text('Real')),
          DropdownMenuItem(value: 'Riesgo', child: Text('Riesgo')),
          DropdownMenuItem(
            value: 'Promoción de la salud',
            child: Text(
              'Promoción de la salud',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        onChanged: (v) => setState(() => tipoDiagnostico = v ?? tipoDiagnostico),
        decoration: const InputDecoration(labelText: 'Tipo de diagnóstico'),
      );

  Widget _dropdownPrioridad() => DropdownButtonFormField<String>(
        initialValue: prioridad,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'Alta', child: Text('Alta')),
          DropdownMenuItem(value: 'Media', child: Text('Media')),
          DropdownMenuItem(value: 'Baja', child: Text('Baja')),
        ],
        onChanged: (v) => setState(() => prioridad = v ?? prioridad),
        decoration: const InputDecoration(labelText: 'Prioridad'),
      );

  Widget _addItem({required String label, required Function(String) onAdd}) {
    final ctrl = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: ctrl,
            decoration: InputDecoration(labelText: label),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF660033)),
          onPressed: () {
            if (ctrl.text.isNotEmpty) {
              onAdd(ctrl.text);
              ctrl.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _list(List<String> items) {
    if (items.isEmpty) return const Text('—');
    return Column(
      children: items
          .map(
            (e) => ListTile(
              leading: const Icon(Icons.circle, size: 8),
              title: Text(e),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => setState(() => items.remove(e)),
              ),
            ),
          )
          .toList(),
    );
  }
}

/*──────────────────── Pdf Viewer Screen ────────────────────*/

class _PdfViewerScreen extends StatefulWidget {
  final Future<PdfDocument> documentFuture;
  final String title;
  final int initialPage;

  const _PdfViewerScreen({
    required this.documentFuture,
    required this.title,
    this.initialPage = 1,
    Key? key,
  }) : super(key: key);

  @override
  State<_PdfViewerScreen> createState() => __PdfViewerScreenState();
}

class __PdfViewerScreenState extends State<_PdfViewerScreen> {
  PdfController? _controller;
  PdfControllerPinch? _controllerPinch;

  @override
  void initState() {
    super.initState();
    // El paquete pdfx no soporta PdfViewPinch en Windows -> usar PdfView (sin pinch)
    if (Platform.isWindows) {
      _controller = PdfController(
        document: widget.documentFuture,
        initialPage: widget.initialPage,
      );
    } else {
      _controllerPinch = PdfControllerPinch(
        document: widget.documentFuture,
        initialPage: widget.initialPage,
      );
    }
  }

  @override
  void dispose() {
    // disponemos solo del controlador que exista
    _controller?.dispose();
    _controllerPinch?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF660033),
      ),
      body: Builder(builder: (_) {
        if (Platform.isWindows) {
          // PdfView es la implementación soportada en Windows
          return PdfView(
            controller: _controller!,
          );
        } else {
          return PdfViewPinch(
            controller: _controllerPinch!,
          );
        }
      }),
    );
  }
}

/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
