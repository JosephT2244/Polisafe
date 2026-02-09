/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../../../services/noc_service.dart';
import '../../../services/nic_service.dart';

// HISTORIAL
import '../../../models/paes_historial.dart';
import '../../../services/paes_historial_service.dart';

class PaesPlanificacionScreen extends StatefulWidget {
  final String nandaCodigo;

  const PaesPlanificacionScreen({
    super.key,
    required this.nandaCodigo,
  });

  @override
  State<PaesPlanificacionScreen> createState() =>
      _PaesPlanificacionScreenState();
}

class _PaesPlanificacionScreenState extends State<PaesPlanificacionScreen> {
  final _formKey = GlobalKey<FormState>();

  // color gris solicitado para iconos
  static const Color _iconGrey = Color.fromARGB(200, 255, 255, 255);

  // ───── NOC ─────
  final TextEditingController nocCodigoCtrl = TextEditingController();
  final TextEditingController nocEtiquetaCtrl = TextEditingController();
  final TextEditingController nocDefinicionCtrl = TextEditingController();
  final TextEditingController searchNocCtrl = TextEditingController();

  // ───── NOC (dominio/clase) - NUEVO ─────
  final TextEditingController nocDominioCtrl = TextEditingController();
  final TextEditingController nocClaseCtrl = TextEditingController();

  // ───── NIC ─────
  final TextEditingController nicCodigoCtrl = TextEditingController();
  final TextEditingController nicEtiquetaCtrl = TextEditingController();
  final TextEditingController nicDefinicionCtrl = TextEditingController();
  final TextEditingController searchNicCtrl = TextEditingController();

  // ───── NIC (dominio/clase) - NUEVO ─────
  final TextEditingController nicDominioCtrl = TextEditingController();
  final TextEditingController nicClaseCtrl = TextEditingController();

  List<Map<String, dynamic>> resultadosNoc = [];
  List<Map<String, dynamic>> resultadosNic = [];

  // ───── Objetivos ─────
  final List<Map<String, dynamic>> objetivos = [];
  String plazo = 'Corto plazo';

  bool _loadingRelated = false;
  bool _searchingNoc = false;
  bool _searchingNic = false;

  @override
  void initState() {
    super.initState();
    // cargamos NOC/NIC relacionados con el NANDA (maneja Future o retorno síncrono)
    _loadRelated();
  }

  // ---------------------
  // Helper para convertir cualquier retorno en List<Map<String,dynamic>>
  // ---------------------
  List<Map<String, dynamic>> _toMapList(dynamic raw) {
    if (raw == null) return <Map<String, dynamic>>[];
    try {
      // Si ya es una lista compatible
      if (raw is List) {
        return List<Map<String, dynamic>>.from(raw.map((e) {
          if (e is Map<String, dynamic>) return e;
          return Map<String, dynamic>.from(e);
        }));
      }
      // Si es un iterable distinto
      if (raw is Iterable) {
        return raw.map((e) {
          if (e is Map<String, dynamic>) return e;
          return Map<String, dynamic>.from(e);
        }).toList();
      }
    } catch (_) {
      // ignore and return empty below
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> _loadRelated() async {
    if (_loadingRelated) return;
    _loadingRelated = true;
    try {
      final resNocRaw =
          await Future.value(NocService.byNanda(widget.nandaCodigo));
      final resNicRaw =
          await Future.value(NicService.byNanda(widget.nandaCodigo));

      final resNoc = _toMapList(resNocRaw);
      final resNic = _toMapList(resNicRaw);

      if (!mounted) return;
      setState(() {
        resultadosNoc = resNoc;
        resultadosNic = resNic;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        resultadosNoc = [];
        resultadosNic = [];
      });
    } finally {
      _loadingRelated = false;
    }
  }

  void _guardarPlanificacion() {
    if (!_formKey.currentState!.validate()) return;

    final contenido = '''
NANDA: ${widget.nandaCodigo}

NOC:
${nocCodigoCtrl.text} - ${nocEtiquetaCtrl.text}
Dominio: ${nocDominioCtrl.text}
Clase: ${nocClaseCtrl.text}
${nocDefinicionCtrl.text}

OBJETIVOS:
${objetivos.map((o) => '- ${o['descripcion']} (${o['plazo']}) ${o['inicial']} → ${o['esperado']}${o.containsKey('dominio') ? ' • Dominio: ${o['dominio']}' : ''}${o.containsKey('clase') ? ' • Clase: ${o['clase']}' : ''}').join('\n')}

NIC:
${nicCodigoCtrl.text} - ${nicEtiquetaCtrl.text}
Dominio: ${nicDominioCtrl.text}
Clase: ${nicClaseCtrl.text}
${nicDefinicionCtrl.text}
''';

    PaesHistorialService.agregar(
      PaesHistorialItem(
        etapa: PaesEtapa.planificacion,
        contenido: contenido,
        fecha: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Planificación guardada en el historial'),
      ),
    );

    // Limpiar todo para nueva planificación
    setState(() {
      nocCodigoCtrl.clear();
      nocEtiquetaCtrl.clear();
      nocDefinicionCtrl.clear();
      nocDominioCtrl.clear();
      nocClaseCtrl.clear();
      searchNocCtrl.clear();
      resultadosNoc = [];

      nicCodigoCtrl.clear();
      nicEtiquetaCtrl.clear();
      nicDefinicionCtrl.clear();
      nicDominioCtrl.clear();
      nicClaseCtrl.clear();
      searchNicCtrl.clear();
      resultadosNic = [];

      objetivos.clear();
      plazo = 'Corto plazo';
    });
  }

  /*──────────────────── MOSTRAR HISTORIAL ────────────────────*/
  void _verHistorial() {
    final historial =
        PaesHistorialService.obtenerPorEtapa(PaesEtapa.planificacion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Historial de Planificación'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay planificaciones registradas.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (_, index) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Planificación ${index + 1}'),
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

  /*──────────────────── MOSTRAR DIALOGO PARA SELECCIONAR PDF (NOC / NIC) ────────────────────*/
  Future<void> _onPdfButtonPressed() async {
    final sel = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Seleccionar libro PDF'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'NOC'),
            child: const Text('Abrir NOC'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'NIC'),
            child: const Text('Abrir NIC'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (sel == null) return;

    if (sel == 'NOC') {
      await _openPdfViewer(
          assetPath: 'assets/data/noc.pdf', title: 'NOC', initialPage: 1);
    } else if (sel == 'NIC') {
      await _openPdfViewer(
          assetPath: 'assets/data/nic.pdf', title: 'NIC', initialPage: 1);
    }
  }

  /*──────────────────── AGREGAR AUTOMÁTICAMENTE NOC/NIC COMO OBJETIVO ────────────────────*/
  void _agregarObjetivoDesdeNOC(Map<String, dynamic> noc) {
    setState(() {
      objetivos.add({
        'descripcion': noc['etiqueta'] ?? '',
        'inicial': 1,
        'esperado': 5,
        'plazo': plazo,
        'dominio': noc['dominio'] ?? '',
        'clase': noc['clase'] ?? '',
      });
    });
  }

  void _agregarObjetivoDesdeNIC(Map<String, dynamic> nic) {
    setState(() {
      objetivos.add({
        'descripcion': nic['etiqueta'] ?? '',
        'inicial': 1,
        'esperado': 5,
        'plazo': plazo,
        'dominio': nic['dominio'] ?? '',
        'clase': nic['clase'] ?? '',
      });
    });
  }

  // ======================================================================
  // utilidades para normalizar / extraer código desde la query
  // ======================================================================
  String _normalize(String s) => s.trim().toLowerCase();

  String? _extractDigits(String q) {
    final reg = RegExp(r'(\d{2,5})'); // acepta códigos de 2 a 5 dígitos
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
      final intCode =
          int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), ''));
      if (intExtracted != null && intCode != null && intExtracted == intCode) {
        return true;
      }
      if (extracted == code) return true;
    }

    if (q == code) return true;

    return false;
  }

  // ======================================================================
  // funciones robustas de búsqueda NOC / NIC (mejoradas)
  // ======================================================================
  Future<void> _searchNoc(String q) async {
    if (_searchingNoc) return;
    _searchingNoc = true;
    try {
      final resRaw = await Future.value(NocService.search(q));
      final res = _toMapList(resRaw);
      if (!mounted) return;

      setState(() => resultadosNoc = res);

      // Autoselección: si solo hay 1 resultado y coincide exactamente con la query
      if (res.length == 1 && _exactMatchWithQuery(res[0], q)) {
        final n = res[0];
        nocCodigoCtrl.text = n['codigo'] ?? '';
        nocEtiquetaCtrl.text = n['etiqueta'] ?? '';
        nocDefinicionCtrl.text = n['definicion'] ?? '';
        nocDominioCtrl.text = n['dominio'] ?? '';
        nocClaseCtrl.text = n['clase'] ?? '';

        setState(() {
          resultadosNoc = [];
          searchNocCtrl.clear();
        });

        _agregarObjetivoDesdeNOC(n);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => resultadosNoc = []);
    } finally {
      _searchingNoc = false;
    }
  }

  Future<void> _searchNic(String q) async {
    if (_searchingNic) return;
    _searchingNic = true;
    try {
      final resRaw = await Future.value(NicService.search(q));
      final res = _toMapList(resRaw);
      if (!mounted) return;

      setState(() => resultadosNic = res);

      if (res.length == 1 && _exactMatchWithQuery(res[0], q)) {
        final n = res[0];
        nicCodigoCtrl.text = n['codigo'] ?? '';
        nicEtiquetaCtrl.text = n['etiqueta'] ?? '';
        nicDefinicionCtrl.text = n['definicion'] ?? '';
        nicDominioCtrl.text = n['dominio'] ?? '';
        nicClaseCtrl.text = n['clase'] ?? '';

        setState(() {
          resultadosNic = [];
          searchNicCtrl.clear();
        });

        _agregarObjetivoDesdeNIC(n);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => resultadosNic = []);
    } finally {
      _searchingNic = false;
    }
  }

  // ==========================================================
  // FUNCIONES PARA ABRIR EL PDF DEL CATÁLOGO (NOC/NIC) Y NAVEGAR
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
      final path =
          await _copyAssetPdfToTemp(assetPath, title.replaceAll(' ', '_') + '.pdf');

      // Producimos un Future<PdfDocument> y lo pasamos al viewer
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
    nocCodigoCtrl.dispose();
    nocEtiquetaCtrl.dispose();
    nocDefinicionCtrl.dispose();
    searchNocCtrl.dispose();
    nocDominioCtrl.dispose();
    nocClaseCtrl.dispose();

    nicCodigoCtrl.dispose();
    nicEtiquetaCtrl.dispose();
    nicDefinicionCtrl.dispose();
    searchNicCtrl.dispose();
    nicDominioCtrl.dispose();
    nicClaseCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planificación de Cuidados de Enfermería',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
          ),
        ),        backgroundColor: const Color(0xFF660033),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            color: _iconGrey,
            tooltip: 'Abrir libro PDF (NOC/NIC)',
            onPressed: _onPdfButtonPressed,
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
              /*═══════════════ NOC ═══════════════*/
              _sectionTitle('Resultados esperados (NOC)'),
              TextFormField(
                controller: searchNocCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar NOC por código o etiqueta',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  _searchNoc(v);
                },
              ),
              const SizedBox(height: 8),
              _listaResultados(
                resultadosNoc,
                pdf: 'assets/data/noc.pdf',
                onSelect: (n) {
                  nocCodigoCtrl.text = n['codigo'] ?? '';
                  nocEtiquetaCtrl.text = n['etiqueta'] ?? '';
                  nocDefinicionCtrl.text = n['definicion'] ?? '';
                  nocDominioCtrl.text = n['dominio'] ?? '';
                  nocClaseCtrl.text = n['clase'] ?? '';

                  setState(() {
                    resultadosNoc = [];
                    searchNocCtrl.clear();
                  });

                  // Agregar automáticamente como objetivo
                  _agregarObjetivoDesdeNOC(n);
                },
                onOpenPdf: (n) {
                  final pageRaw = n['pagina_pdf'] ?? n['pagina'] ?? 1;
                  final page = int.tryParse(pageRaw.toString()) ?? 1;
                  _openPdfViewer(
                      assetPath: 'assets/data/noc.pdf',
                      title: 'NOC',
                      initialPage: page);
                },
              ),
              _text(nocCodigoCtrl, 'Código NOC'),
              _text(nocEtiquetaCtrl, 'Etiqueta del resultado'),
              _text(nocDominioCtrl, 'Dominio'),
              _text(nocClaseCtrl, 'Clase'),
              _textArea(nocDefinicionCtrl, 'Definición'),

              /*═══════════════ OBJETIVOS ═══════════════*/
              _sectionTitle('Objetivos de enfermería'),
              _dropdownPlazo(),
              _addObjetivo(),
              _listaObjetivos(),

              /*═══════════════ NIC ═══════════════*/
              _sectionTitle('Intervenciones (NIC)'),
              TextFormField(
                controller: searchNicCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar NIC por código o etiqueta',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  _searchNic(v);
                },
              ),
              const SizedBox(height: 8),
              _listaResultados(
                resultadosNic,
                pdf: 'assets/data/nic.pdf',
                onSelect: (n) {
                  nicCodigoCtrl.text = n['codigo'] ?? '';
                  nicEtiquetaCtrl.text = n['etiqueta'] ?? '';
                  nicDefinicionCtrl.text = n['definicion'] ?? '';
                  nicDominioCtrl.text = n['dominio'] ?? '';
                  nicClaseCtrl.text = n['clase'] ?? '';

                  setState(() {
                    resultadosNic = [];
                    searchNicCtrl.clear();
                  });

                  // Agregar automáticamente como objetivo
                  _agregarObjetivoDesdeNIC(n);
                },
                onOpenPdf: (n) {
                  final pageRaw = n['pagina_pdf'] ?? n['pagina'] ?? 1;
                  final page = int.tryParse(pageRaw.toString()) ?? 1;
                  _openPdfViewer(
                      assetPath: 'assets/data/nic.pdf',
                      title: 'NIC',
                      initialPage: page);
                },
              ),
              _text(nicCodigoCtrl, 'Código NIC'),
              _text(nicEtiquetaCtrl, 'Etiqueta de la intervención'),
              _text(nicDominioCtrl, 'Dominio'),
              _text(nicClaseCtrl, 'Clase'),
              _textArea(nicDefinicionCtrl, 'Definición'),

              const SizedBox(height: 30),

              // ---------- BOTÓN GUARDAR ----------
              SizedBox(
                width: double.infinity, // ocupa todo el ancho disponible (más largo)
                child: ElevatedButton.icon(
                  onPressed: _guardarPlanificacion,
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _dropdownPlazo() => DropdownButtonFormField<String>(
        initialValue: plazo,
        items: const [
          DropdownMenuItem(value: 'Corto plazo', child: Text('Corto plazo')),
          DropdownMenuItem(value: 'Mediano plazo', child: Text('Mediano plazo')),
          DropdownMenuItem(value: 'Largo plazo', child: Text('Largo plazo')),
        ],
        onChanged: (v) => setState(() => plazo = v ?? plazo),
        decoration: const InputDecoration(labelText: 'Plazo del objetivo'),
      );

  Widget _addObjetivo() {
    final descCtrl = TextEditingController();
    int inicial = 1;
    int esperado = 5;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Objetivo medible'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: inicial,
                    items: List.generate(
                      5,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Inicial ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) => inicial = v ?? inicial,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: esperado,
                    items: List.generate(
                      5,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Esperado ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) => esperado = v ?? esperado,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF660033)),
                onPressed: () {
                  if (descCtrl.text.isNotEmpty) {
                    setState(() {
                      objetivos.add({
                        'descripcion': descCtrl.text,
                        'inicial': inicial,
                        'esperado': esperado,
                        'plazo': plazo,
                      });
                    });
                    descCtrl.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaObjetivos() {
    if (objetivos.isEmpty) return const Text('No hay objetivos registrados');

    return Column(
      children: objetivos.map((o) {
        return ListTile(
          title: Text(o['descripcion']),
          subtitle: Text(
            'Inicial ${o['inicial']} → Esperado ${o['esperado']} (${o['plazo']})'
            '${o.containsKey('dominio') && (o['dominio'] as String).isNotEmpty ? ' • Dominio: ${o['dominio']}' : ''}'
            '${o.containsKey('clase') && (o['clase'] as String).isNotEmpty ? ' • Clase: ${o['clase']}' : ''}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            color: _iconGrey,
            onPressed: () => setState(() => objetivos.remove(o)),
          ),
        );
      }).toList(),
    );
  }

  // items: lista, pdf: ruta asset pdf correspondiente, onSelect: callback al seleccionar
  Widget _listaResultados(
    List<Map<String, dynamic>> items, {
    required String pdf,
    required Function(Map<String, dynamic>) onSelect,
    required Function(Map<String, dynamic>) onOpenPdf,
  }) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      children: items.map((n) {
        return Card(
          child: ListTile(
            title: Text('${n['codigo']} – ${n['etiqueta']}'),
            subtitle: Text('${n['dominio'] ?? '-'} • ${n['clase'] ?? '-'}'),
            onTap: () => onSelect(n),
            onLongPress: () => onOpenPdf(n),
          ),
        );
      }).toList(),
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
    // pdfx: PdfViewPinch no está soportado en Windows => usar PdfView en Windows
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
          return PdfView(controller: _controller!);
        } else {
          return PdfViewPinch(controller: _controllerPinch!);
        }
      }),
    );
  }
}

/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
