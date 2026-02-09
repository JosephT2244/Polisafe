/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class EstudioScreen extends StatefulWidget {
  const EstudioScreen({super.key});

  @override
  State<EstudioScreen> createState() => _EstudioScreenState();
}

class _EstudioScreenState extends State<EstudioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _busquedaGeneralController =
      TextEditingController();
  final TextEditingController _busquedaTerminologiasController =
      TextEditingController();
  final TextEditingController _busquedaNormasController =
      TextEditingController();

  String _busquedaGeneral = "";
  String _busquedaTerminologias = "";
  String _busquedaNormas = "";

  // debounce timers
  Timer? _debounceGeneral;
  Timer? _debounceTerminologias;
  Timer? _debounceNormas;

  final Set<String> _favoritos = {};
  final List<String> _historial = [];

  bool _isExporting = false;

  // Asset cache to avoid repeated rootBundle loads
  final Map<String, Uint8List?> _assetCache = {};

  // Cached sorted copies (avoid sorting repeatedly)
  List<Map<String, String>>? _terminologiasOrdenadasCache;
  List<Map<String, String>>? _tablasOrdenadasCache;
  List<Map<String, String>>? _normasOrdenadasCache;

  // Paleta clara: Guinda + Blanco + Crema (SIN DEGRADADOS)
  static const Color _fondo = Color(0xFFFDF7F3);
  static const Color _guinda = Color(0xFF7A0019);
  static const Color _guindaClaro = Color(0xFF9A1230);
  static const Color _crema = Color(0xFFF5E6D3);
  static const Color _negroTexto = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Debounced listeners to reduce frequent setState calls while typing
    _busquedaGeneralController.addListener(() {
      _debounceGeneral?.cancel();
      _debounceGeneral = Timer(const Duration(milliseconds: 300), () {
        final newVal = _busquedaGeneralController.text.trim().toLowerCase();
        if (newVal != _busquedaGeneral) {
          setState(() => _busquedaGeneral = newVal);
        }
      });
    });

    _busquedaTerminologiasController.addListener(() {
      _debounceTerminologias?.cancel();
      _debounceTerminologias = Timer(const Duration(milliseconds: 300), () {
        final newVal =
            _busquedaTerminologiasController.text.trim().toLowerCase();
        if (newVal != _busquedaTerminologias) {
          setState(() => _busquedaTerminologias = newVal);
        }
      });
    });

    _busquedaNormasController.addListener(() {
      _debounceNormas?.cancel();
      _debounceNormas = Timer(const Duration(milliseconds: 300), () {
        final newVal = _busquedaNormasController.text.trim().toLowerCase();
        if (newVal != _busquedaNormas) {
          setState(() => _busquedaNormas = newVal);
        }
      });
    });

    // Preload frequently used assets in background (non-blocking)
    _preloadAssets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaGeneralController.dispose();
    _busquedaTerminologiasController.dispose();
    _busquedaNormasController.dispose();
    _debounceGeneral?.cancel();
    _debounceTerminologias?.cancel();
    _debounceNormas?.cancel();
    super.dispose();
  }

  // ==============================
  // TERMINOLOGÍAS (DATOS)
  // ==============================

  final List<Map<String, String>> _terminologias = [
    {
      "titulo": "CEFALEA",
      "descripcion":
          "Dolor o sensación desagradable en cualquier parte de la cabeza, incluyendo la parte superior o posterior de la cabeza y la cara. Comúnmente conocido como dolor de cabeza."
    },
    {
      "titulo": "MIALGIA",
      "descripcion":
          "Dolor o malestar que afecta a uno o varios músculos del cuerpo. Puede ser resultado de sobreesfuerzo, procesos inflamatorios o enfermedades sistémicas."
    },
    {
      "titulo": "ARTRALGIA",
      "descripcion":
          "Dolor localizado en las articulaciones. A diferencia de la artritis, la artralgia se refiere específicamente al síntoma del dolor, independientemente de si existe inflamación visible o no."
    },
    {
      "titulo": "LUMBALGIA",
      "descripcion":
          "Dolor situado en la región lumbar de la espalda (la parte baja). Es una de las causas más frecuentes de consulta y puede ser de origen muscular, óseo o nervioso."
    },
    {
      "titulo": "DOLOR ABDOMINAL",
      "descripcion":
          "Sensación dolorosa que se percibe en el área comprendida entre el tórax y la pelvis. En clínica, suele dividirse por cuadrantes para facilitar el diagnóstico diferencial."
    },
    {
      "titulo": "DOLOR TORÁCICO",
      "descripcion":
          "Dolor o molestia que se siente en cualquier punto de la parte frontal del cuerpo, entre el cuello y la parte superior del abdomen. Es un síntoma crítico que requiere descartar causas cardiacas o pulmonares de urgencia."
    },
    {
      "titulo": "NÁUSEA",
      "descripcion":
          "Sensación subjetiva de malestar e incomodidad en la parte superior del abdomen, que suele preceder al vómito y a menudo se acompaña de salivación, sudoración y mareo."
    },
    {
      "titulo": "EMESIS",
      "descripcion":
          "El acto de expulsar de forma forzada el contenido gástrico a través de la boca. Es el término médico para el vómito."
    },
    {
      "titulo": "DIARREA",
      "descripcion":
          "Alteración de las evacuaciones intestinales caracterizada por un aumento en la frecuencia (habitualmente más de 3 veces al día) y una disminución en la consistencia de las heces (líquidas o semilíquidas)."
    },
    {
      "titulo": "DISTENSIÓN ABDOMINAL",
      "descripcion":
          "Aumento del volumen del abdomen debido a la acumulación de gas, líquidos o sólidos en el tracto gastrointestinal. Comúnmente el paciente lo describe como estar \"hinchado\" o \"aventado\"."
    },
    {
      "titulo": "HEMATEMESIS",
      "descripcion":
          "Vómito de sangre fresca (roja brillante) o digerida (con aspecto de \"posos de café\"). Indica una hemorragia digestiva alta, generalmente por encima del ángulo de Treitz."
    },
    {
      "titulo": "MELENA",
      "descripcion":
          "Evacuación de heces negras, alquitranadas y de olor fétido debido a la presencia de sangre digerida. Suele indicar sangrado del tracto digestivo superior."
    },
    {
      "titulo": "HEMATOQUECIA",
      "descripcion":
          "Expulsión de sangre roja brillante o rutilante a través del ano, sola o mezclada con las heces. Generalmente sugiere una hemorragia digestiva baja."
    },
    {
      "titulo": "MAREO",
      "descripcion":
          "Sensación de inseguridad, aturdimiento o inestabilidad espacial, sin que exista una sensación de movimiento rotatorio. Es un término subjetivo y menos específico que el vértigo."
    },
    {
      "titulo": "VÉRTIGO",
      "descripcion":
          "Sensación errónea de movimiento, habitualmente rotatorio, ya sea de uno mismo o del entorno (sentir que \"todo da vueltas\"). Generalmente está relacionado con alteraciones en el sistema vestibular (oído interno)."
    },
    {
      "titulo": "SÍNCOPE",
      "descripcion":
          "Pérdida brusca y temporal de la conciencia y del tono muscular, de corta duración y con recuperación espontánea completa. Se debe a una disminución transitoria del flujo sanguíneo cerebral."
    },
    {
      "titulo": "CONVULSIONES",
      "descripcion":
          "Alteraciones eléctricas repentinas y descontroladas en el cerebro que pueden causar cambios en el comportamiento, los movimientos, los sentimientos y en los niveles de conciencia."
    },
    {
      "titulo": "PARESTESIAS",
      "descripcion":
          "Sensación anormal de hormigueo, adormecimiento o \"pinchazos\" en la piel, que ocurre sin un estímulo externo evidente."
    },
    {
      "titulo": "DEBILIDAD MUSCULAR",
      "descripcion":
          "Reducción de la fuerza en uno o más músculos, que impide realizar tareas que normalmente el paciente podría ejecutar."
    },
    {
      "titulo": "DISNEA",
      "descripcion":
          "Sensación subjetiva de falta de aire o dificultad para respirar."
    },
    {
      "titulo": "TOS",
      "descripcion":
          "Reflejo defensivo del cuerpo para limpiar las vías respiratorias de mucosidad, sustancias extrañas o irritantes."
    },
    {
      "titulo": "EXPECTORACIÓN",
      "descripcion":
          "Acto de arrancar y arrojar por la boca las flemas y secreciones."
    },
    {
      "titulo": "HEMOPTISIS",
      "descripcion":
          "Expulsión de sangre roja y espumosa procedente de las vías respiratorias inferiores."
    },
    {
      "titulo": "SIBILANCIAS",
      "descripcion":
          "Sonidos agudos y silbantes durante la respiración cuando las vías aéreas están estrechadas."
    },
    {
      "titulo": "ORTOPNEA",
      "descripcion":
          "Disnea que ocurre cuando el paciente está acostado y que le obliga a sentarse para respirar mejor."
    },
    {
      "titulo": "DOLOR PRECORDIAL",
      "descripcion":
          "Dolor o malestar localizado en la parte anterior del tórax, por delante del corazón."
    },
    {
      "titulo": "PALPITACIONES",
      "descripcion":
          "Percepción subjetiva del latido cardiaco, como vibración o latidos fuertes."
    },
    {
      "titulo": "EDEMA",
      "descripcion":
          "Acumulación anormal de líquido en los tejidos, provocando hinchazón visible."
    },
    {
      "titulo": "CIANOSIS",
      "descripcion":
          "Coloración azulada o violácea de la piel y las mucosas debido a oxigenación insuficiente."
    },
    {
      "titulo": "DISURIA",
      "descripcion": "Dolor, ardor o escozor al orinar."
    },
    {
      "titulo": "POLAQUIURIA",
      "descripcion": "Aumento en la frecuencia de micciones con bajo volumen."
    },
    {
      "titulo": "HEMATURIA",
      "descripcion": "Presencia de sangre en la orina."
    },
    {
      "titulo": "OLIGURIA",
      "descripcion": "Disminución de producción de orina por debajo de lo normal."
    },
    {
      "titulo": "ANURIA",
      "descripcion": "Ausencia casi total de eliminación de orina."
    },
    {
      "titulo": "FIEBRE",
      "descripcion": "Elevación de temperatura corporal generalmente mayor a 38°C."
    },
    {
      "titulo": "ASTENIA",
      "descripcion": "Sensación generalizada de cansancio y fatiga."
    },
    {
      "titulo": "ADINAMIA",
      "descripcion": "Falta de fuerza o dificultad para iniciar actividad física."
    },
    {
      "titulo": "ANOREXIA",
      "descripcion": "Pérdida del apetito."
    },
    {
      "titulo": "DIAFORESIS",
      "descripcion": "Sudoración excesiva no relacionada con calor."
    },
    {
      "titulo": "PÉRDIDA DE PESO INVOLUNTARIA",
      "descripcion":
          "Reducción de peso sin dieta o ejercicio; significativa si supera 5-10% en 6 meses."
    },
  ];

  // ==============================
  // TABLAS (JPG)
  // ==============================

  final List<Map<String, String>> _tablas = [
    {
      "titulo": "COMO ELEGIR EL CATETER ADECUADO",
      "asset": "assets/estudio/tablas/cateter.jpg"
    },
    {
      "titulo": "LOS 5 MOMENTOS para la Higiene de las Manos",
      "asset": "assets/estudio/tablas/5_momentos.jpg"
    },
    {
      "titulo": "Índice de masa corporal",
      "asset": "assets/estudio/tablas/imc.jpg"
    },
    {
      "titulo": "¿Cómo lavarse las manos?",
      "asset": "assets/estudio/tablas/lavado_manos.jpg"
    },
  ];

  // ==============================
  // NORMAS (PNG)
  // ==============================

  final List<Map<String, String>> _normas = [
    {"titulo": "NOM-022-SSA3-2012", "asset": "assets/estudio/normas/1.png"},
    {"titulo": "NOM-072-SSA1-2012", "asset": "assets/estudio/normas/2.png"},
    {"titulo": "NOM-073-SSA1-2015", "asset": "assets/estudio/normas/3.png"},
    {"titulo": "NOM-045-SSA2-2005", "asset": "assets/estudio/normas/4.png"},
    {"titulo": "NOM-017-SSA2-2012", "asset": "assets/estudio/normas/5.png"},
    {"titulo": "NOM-087-ECOL-SSA1-2002", "asset": "assets/estudio/normas/6.png"},
    {"titulo": "NOM-004-SSA3-2012", "asset": "assets/estudio/normas/7.png"},
    {"titulo": "NOM-019-SSA3-2013", "asset": "assets/estudio/normas/8.png"},
    {"titulo": "NOM-036-SSA2-2012", "asset": "assets/estudio/normas/9.png"},
    {"titulo": "NOM-006-SSA2-2013", "asset": "assets/estudio/normas/10.png"},
    {"titulo": "NOM-253-SSA1-2012", "asset": "assets/estudio/normas/11.png"},
  ];

  // ==============================
  // FILTROS
  // ==============================

  List<Map<String, String>> get _terminologiasFiltradas {
    final query = ("$_busquedaGeneral $_busquedaTerminologias").trim();
    if (query.isEmpty) return _terminologias;

    return _terminologias.where((t) {
      final titulo = t["titulo"]!.toLowerCase();
      final descripcion = t["descripcion"]!.toLowerCase();
      return titulo.contains(query) || descripcion.contains(query);
    }).toList();
  }

  List<Map<String, String>> get _normasFiltradas {
    final query = ("$_busquedaGeneral $_busquedaNormas").trim();
    if (query.isEmpty) return _normas;

    return _normas.where((n) {
      final titulo = n["titulo"]!.toLowerCase();
      return titulo.contains(query);
    }).toList();
  }

  List<Map<String, String>> get _tablasFiltradas {
    final query = _busquedaGeneral.trim().toLowerCase();
    if (query.isEmpty) return _tablas;

    return _tablas.where((t) {
      final titulo = t["titulo"]!.toLowerCase();
      return titulo.contains(query);
    }).toList();
  }

  // ==============================
  // UTILIDADES PDF (ESTABLES)
  // ==============================

  Future<Uint8List?> _loadAssetBytesSafe(String assetPath) async {
    try {
      // usar cache si existe
      if (_assetCache.containsKey(assetPath)) return _assetCache[assetPath];
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      _assetCache[assetPath] = bytes;
      return bytes;
    } catch (_) {
      _assetCache[assetPath] = null; // recordar intento fallido
      return null;
    }
  }

  pw.Widget _pdfTituloSeccion(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF7A0019),
        ),
      ),
    );
  }

  // chunk helper
  List<List<T>> _chunkList<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(
          i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  // ==============================
  // GUARDAR IMAGEN (disponible para UI)
  // ==============================
  Future<void> _guardarImagenAsset(String assetPath, String nombre) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$nombre");

      await file.writeAsBytes(bytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Imagen guardada en:\n${file.path}"),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar imagen: $e"),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  // ==============================
  // EXPORT: GENERADOR DE PDF (bytes)
  // ==============================
  // Parámetros controlables para evitar demasiadas páginas
    Future<Uint8List> _generatePdfBytes({
      required bool includeTerminologias,
      required bool includeTablas,
      required bool includeNormas,
      int maxTerminologias = 200,
      int maxTablas = 40,
      int maxNormas = 40,
    }) async {
      final pdf = pw.Document();

    // cached sorted copies
    _terminologiasOrdenadasCache ??= [..._terminologias]
      ..sort((a, b) => a["titulo"]!.compareTo(b["titulo"]!));
    _normasOrdenadasCache ??= [..._normas]
      ..sort((a, b) => a["titulo"]!.compareTo(b["titulo"]!));
    _tablasOrdenadasCache ??= [..._tablas]
      ..sort((a, b) => a["titulo"]!.compareTo(b["titulo"]!));

    final terminologiasOrdenadas = _terminologiasOrdenadasCache!;
    final normasOrdenadas = _normasOrdenadasCache!;
    final tablasOrdenadas = _tablasOrdenadasCache!;

    // IMPORTANT: si el usuario quiere incluir terminologías, incluimos **todas**
    final terminologiasParaPdf = includeTerminologias
        ? terminologiasOrdenadas
        : terminologiasOrdenadas.take(maxTerminologias).toList();

    final tablasParaPdf = tablasOrdenadas.take(maxTablas).toList();
    final normasParaPdf = normasOrdenadas.take(maxNormas).toList();

    // Cargar bytes (usar cache)
    final List<Map<String, dynamic>> tablasConBytes = [];
    for (final t in tablasParaPdf) {
      final bytes = await _loadAssetBytesSafe(t["asset"]!);
      tablasConBytes.add({...t, "bytes": bytes});
    }

    final List<Map<String, dynamic>> normasConBytes = [];
    for (final n in normasParaPdf) {
      final bytes = await _loadAssetBytesSafe(n["asset"]!);
      normasConBytes.add({...n, "bytes": bytes});
    }

    final logoBytes = await _loadAssetBytesSafe("assets/logo.jpg");
    final pw.ImageProvider? logoProvider =
        logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    // formato y límites de imagen
    final pageFormat = PdfPageFormat.a4;
    const pageMargin = 28.0;
    final contentWidth = pageFormat.width - (pageMargin * 2);
    final maxImageHeight = pageFormat.height * 0.45;

    // Portada
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // LOGO APP
              if (logoProvider != null)
                pw.Container(
                  height: 110,
                  width: 110,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(14),
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFF7A0019),
                      width: 2,
                    ),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 14,
                    verticalRadius: 14,
                    child: pw.Image(
                      logoProvider,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),

              pw.SizedBox(height: 22),

              // TÍTULO
              pw.Text(
                "POLISAFE",
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF7A0019),
                ),
              ),

              pw.SizedBox(height: 6),

              pw.Text(
                "MÓDULO DE ESTUDIO",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF444444),
                ),
              ),

              pw.SizedBox(height: 18),

              // DESCRIPCIÓN
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF7F1EC),
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFDDDDDD),
                  ),
                ),
                child: pw.Text(
                  "Documento generado automáticamente desde la aplicación POLISAFE.\n"
                  "Incluye terminologías, normas NOM y tablas visuales (resumen para impresión).",
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              pw.SizedBox(height: 18),

              // AUTORES
              pw.Text(
                "Autores",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF555555),
                ),
              ),

              pw.SizedBox(height: 6),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "- Joseph Ubaldo Trejo Hernandez",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    "- Sofia Cruz García",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    "- María Guadalupe Cortes Cano",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // FECHA
              pw.Text(
                "Generado: ${DateTime.now().toString().split('.').first}",
                style: pw.TextStyle(
                  fontSize: 9,
                  color: const PdfColor.fromInt(0xFF666666),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Contenido
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(pageMargin),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text("Página ${context.pageNumber} / ${context.pagesCount}",
              style: pw.TextStyle(
                  fontSize: 9,
                  color: const PdfColor.fromInt(0xFF666666))),
        ),
        build: (context) {
          final List<pw.Widget> content = [];

          // Header breve
          content.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("POLISAFE - ESTUDIO",
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF7A0019))),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF7F7F7),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFFDDDDDD)),
                  ),
                  child: pw.Text("Exportación compacta",
                      style: pw.TextStyle(fontSize: 9)),
                ),
              ],
            ),
          );

          content.add(pw.SizedBox(height: 8));
          content.add(pw.Text("Resumen optimizado para impresión.",
              style: pw.TextStyle(
                  fontSize: 10,
                  color: const PdfColor.fromInt(0xFF555555))));
          content.add(pw.SizedBox(height: 10));
          content.add(pw.Divider(color: const PdfColor.fromInt(0xFFCCCCCC)));
          content.add(pw.SizedBox(height: 10));

          // Mini dashboard
          content.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF7F7F7),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFDDDDDD))),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Terminologías: ${_terminologias.length}",
                            style: pw.TextStyle(fontSize: 10)),
                        pw.Text("Tablas: ${_tablas.length}",
                            style: pw.TextStyle(fontSize: 10)),
                        pw.Text("Normas: ${_normas.length}",
                            style: pw.TextStyle(fontSize: 10)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            "Exportando: ${includeTerminologias ? terminologiasParaPdf.length : 0} términos",
                            style: pw.TextStyle(fontSize: 10)),
                        pw.Text("${includeTablas ? tablasParaPdf.length : 0} tablas",
                            style: pw.TextStyle(fontSize: 10)),
                        pw.Text("${includeNormas ? normasParaPdf.length : 0} normas",
                            style: pw.TextStyle(fontSize: 10)),
                      ]),
                ],
              ),
            ),
          );

          content.add(pw.SizedBox(height: 12));

          // Terminologías (compactas en 2 columnas)
          if (includeTerminologias) {
            content.add(_pdfTituloSeccion("Terminologías (resumen)"));
            content.add(pw.SizedBox(height: 8));
            final double cardWidth = (contentWidth - 12) / 2;

            final List<pw.Widget> terminoCards = terminologiasParaPdf.map((t) {
              return pw.Container(
                width: cardWidth,
                margin: const pw.EdgeInsets.only(bottom: 10, right: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFFFFFF),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFECECEC)),
                ),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(t["titulo"]!,
                          style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color:
                                  const PdfColor.fromInt(0xFF7A0019))),
                      pw.SizedBox(height: 4),
                      pw.Text(t["descripcion"]!,
                          style: pw.TextStyle(
                              fontSize: 9,
                              color:
                                  const PdfColor.fromInt(0xFF222222)),
                          maxLines: 6),
                    ]),
              );
            }).toList();

            content.add(pw.Wrap(
                spacing: 6, runSpacing: 6, children: terminoCards));
            content.add(pw.SizedBox(height: 12));
          }

          // Tablas: 2 por fila
          if (includeTablas) {
            content.add(_pdfTituloSeccion("Tablas visuales"));
            content.add(pw.SizedBox(height: 8));

            final tablasChunks =
                _chunkList<Map<String, dynamic>>(tablasConBytes, 2);
            for (final pair in tablasChunks) {
              content.add(
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: pair.map((t) {
                    final hasBytes = t["bytes"] != null;
                    final child = hasBytes
                        ? pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(t["titulo"]!,
                                  style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          pw.FontWeight.bold)),
                              pw.SizedBox(height: 6),
                              pw.Container(
                                width: (contentWidth - 8) / 2,
                                height: maxImageHeight,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: const PdfColor.fromInt(
                                          0xFFDDDDDD)),
                                  borderRadius:
                                      pw.BorderRadius.circular(8),
                                ),
                                child: pw.ClipRRect(
                                  horizontalRadius: 8,
                                  verticalRadius: 8,
                                  child: pw.Image(
                                      pw.MemoryImage(t["bytes"]),
                                      fit: pw.BoxFit.contain),
                                ),
                              ),
                            ],
                          )
                        : pw.Container(
                            width: (contentWidth - 8) / 2,
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                "⚠ Imagen no disponible: ${t["asset"]}",
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: const PdfColor.fromInt(
                                        0xFFAA0000))),
                          );

                    return pw.Expanded(
                        child: pw.Padding(
                            padding:
                                const pw.EdgeInsets.only(right: 6),
                            child: child));
                  }).toList(),
                ),
              );
              content.add(pw.SizedBox(height: 12));
            }
          }

          // Normas: 2 por fila
          if (includeNormas) {
            content.add(pw.SizedBox(height: 10));
            content.add(_pdfTituloSeccion("Normas (imágenes)"));
            content.add(pw.SizedBox(height: 8));

            final normasChunks =
                _chunkList<Map<String, dynamic>>(normasConBytes, 2);
            for (final pair in normasChunks) {
              content.add(
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: pair.map((n) {
                    final hasBytes = n["bytes"] != null;
                    final child = hasBytes
                        ? pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(n["titulo"]!,
                                  style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          pw.FontWeight.bold)),
                              pw.SizedBox(height: 6),
                              pw.Container(
                                width: (contentWidth - 8) / 2,
                                height: maxImageHeight,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: const PdfColor.fromInt(
                                          0xFFDDDDDD)),
                                  borderRadius:
                                      pw.BorderRadius.circular(8),
                                ),
                                child: pw.ClipRRect(
                                  horizontalRadius: 8,
                                  verticalRadius: 8,
                                  child: pw.Image(
                                      pw.MemoryImage(n["bytes"]),
                                      fit: pw.BoxFit.contain),
                                ),
                              ),
                            ],
                          )
                        : pw.Container(
                            width: (contentWidth - 8) / 2,
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                "⚠ Imagen no disponible: ${n["asset"]}",
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: const PdfColor.fromInt(
                                        0xFFAA0000))),
                          );

                    return pw.Expanded(
                        child: pw.Padding(
                            padding:
                                const pw.EdgeInsets.only(right: 6),
                            child: child));
                  }).toList(),
                ),
              );
              content.add(pw.SizedBox(height: 12));
            }
          }

          // Pie
          content.add(pw.SizedBox(height: 14));
          content.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFAFAFA),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFDDDDDD))),
              child: pw.Text(
                "Generado automáticamente desde POLISAFE. Verifique vigencia de normas y procedimientos según su institución.",
                style: pw.TextStyle(
                    fontSize: 9,
                    color: const PdfColor.fromInt(0xFF555555)),
              ),
            ),
          );

          return content;
        },
      ),
    );

    return pdf.save();
  }

  // ==============================
  // EXPORTACIÓN A ARCHIVO Y SHARE
  // ==============================

  Future<void> _exportSelectedPdf({
    required bool includeTerminologias,
    required bool includeTablas,
    required bool includeNormas,
  }) async {
    if (_isExporting) return; // prevenir exportaciones concurrentes
    _isExporting = true;
    try {
      // mostrar feedback inmediato
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Iniciando exportación...")),
        );
      }

      final bytes = await _generatePdfBytes(
        includeTerminologias: includeTerminologias,
        includeTablas: includeTablas,
        includeNormas: includeNormas,
      );

      final dir = await getApplicationDocumentsDirectory();
      final nameParts = [
        "POLISAFE",
        if (includeTerminologias) "T",
        if (includeTablas) "Tab",
        if (includeNormas) "N",
        "compacto.pdf"
      ];
      final filename = nameParts.join("_");
      final file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("PDF guardado en:\n${file.path}"),
            backgroundColor: Colors.green.shade800),
      );

      await Share.shareXFiles([XFile(file.path)],
          text: "POLISAFE - PDF Estudio");
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().toLowerCase().contains("toomanypages")
          ? "El PDF excedió el número de páginas permitido. Intenta reducir secciones o bajar límites."
          : "Error exportando PDF: $e";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(mensaje), backgroundColor: Colors.red.shade800));
    } finally {
      _isExporting = false;
    }
  }

  // ==============================
  // GENERAR VARIOS PDF Y ZIP
  // ==============================
  Future<void> _exportAllAsZip() async {
    if (_isExporting) return;
    _isExporting = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final archive = Archive();

      // Generar PDF por sección (si tienen elementos)
      if (_terminologias.isNotEmpty) {
        final bytesT = await _generatePdfBytes(
            includeTerminologias: true,
            includeTablas: false,
            includeNormas: false);
        archive.addFile(ArchiveFile(
            "POLISAFE_Terminologias.pdf", bytesT.length, bytesT));
      }
      if (_tablas.isNotEmpty) {
        final bytesTab = await _generatePdfBytes(
            includeTerminologias: false,
            includeTablas: true,
            includeNormas: false);
        archive.addFile(ArchiveFile(
            "POLISAFE_Tablas.pdf", bytesTab.length, bytesTab));
      }
      if (_normas.isNotEmpty) {
        final bytesN = await _generatePdfBytes(
            includeTerminologias: false,
            includeTablas: false,
            includeNormas: true);
        archive.addFile(ArchiveFile(
            "POLISAFE_Normas.pdf", bytesN.length, bytesN));
      }

      // Codificar ZIP
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      final zipFile = File("${dir.path}/POLISAFE_ESTUDIO_paquetes.zip");
      await zipFile.writeAsBytes(zipData!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("ZIP guardado en:\n${zipFile.path}"),
            backgroundColor: Colors.green.shade800),
      );

      await Share.shareXFiles([XFile(zipFile.path)],
          text: "POLISAFE - Paquetes (ZIP)");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error generando ZIP: $e"),
          backgroundColor: Colors.red.shade800));
    } finally {
      _isExporting = false;
    }
  }

  // ==============================
  // DIALOG SELECTOR DE EXPORTACIÓN
  // ==============================
  void _showExportOptions() {
    bool sTerminologias = true;
    bool sTablas = true;
    bool sNormas = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(height: 12),
                    const Text("Opciones de exportación",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: sTerminologias,
                      onChanged: (v) =>
                          setLocal(() => sTerminologias = v ?? false),
                      title: const Text("Terminologías"),
                      subtitle: Text("${_terminologias.length} ítems"),
                    ),
                    CheckboxListTile(
                      value: sTablas,
                      onChanged: (v) => setLocal(() => sTablas = v ?? false),
                      title: const Text("Tablas (imágenes)"),
                      subtitle: Text("${_tablas.length} imágenes"),
                    ),
                    CheckboxListTile(
                      value: sNormas,
                      onChanged: (v) => setLocal(() => sNormas = v ?? false),
                      title: const Text("Normas (imágenes)"),
                      subtitle: Text("${_normas.length} imágenes"),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _exportSelectedPdf(
                                includeTerminologias: sTerminologias,
                                includeTablas: sTablas,
                                includeNormas: sNormas,
                              );
                            },
                            child: const Text("Exportar PDF compacto"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700]),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _exportAllAsZip();
                            },
                            child: const Text("Exportar todo (ZIP)"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==============================
  // MOSTRAR HISTORIAL (NUEVO)
  // ==============================
  void _mostrarHistorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Historial de términos",
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: _guinda,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: "Borrar historial",
                    onPressed: () {
                      if (_historial.isEmpty) return;

                      setState(() => _historial.clear());

                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Historial eliminado"),
                          backgroundColor: Colors.red.shade800,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_forever_rounded,
                        color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_historial.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Text(
                    "Aún no has guardado términos en el historial.",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.70),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final termino = _historial[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withOpacity(0.95),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                termino,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _guinda,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: "Eliminar",
                              onPressed: () {
                                setState(() {
                                  _historial.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.black45),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _guinda,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.white),
                label: const Text("Cerrar",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // Preload assets in background to reduce lag during export
  // ==============================
  void _preloadAssets() {
    // no await here to avoid delaying init
    Future(() async {
      try {
        for (final t in _tablas) {
          await _loadAssetBytesSafe(t['asset']!);
        }
        for (final n in _normas) {
          await _loadAssetBytesSafe(n['asset']!);
        }
        await _loadAssetBytesSafe('assets/logo.jpg');
      } catch (_) {
        // precache best-effort: ignorar errores
      }
    });
  }

  // ==============================
  // UI PRINCIPAL
  // ==============================

  @override
  Widget build(BuildContext context) {
    final total = _terminologias.length + _tablas.length + _normas.length;

    return Scaffold(
      backgroundColor: _fondo,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              expandedHeight: 380,
              backgroundColor: _fondo,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const SizedBox.shrink(),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: _fondo,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ENCABEZADO GUINDA PRINCIPAL
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _guinda,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Estudio",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: "Ver historial",
                                    onPressed: _mostrarHistorial,
                                    icon: const Icon(
                                      Icons.history_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: "Exportar PDF",
                                    onPressed: _showExportOptions,
                                    icon: const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Sección diseñada para consulta rápida de terminologías clínicas, normas oficiales NOM y tablas visuales útiles para procedimientos y valoración.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.8,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // BUSCADOR GENERAL
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: _busquedaGeneralController,
                            style: const TextStyle(color: _negroTexto),
                            decoration: InputDecoration(
                              hintText: "Búsqueda general en todo el módulo...",
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.55),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black54,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.95),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _dashboardSuperior(total),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  decoration: BoxDecoration(
                    color: _fondo,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _guinda,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: _guinda,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: "Terminologías"),
                      Tab(text: "Tablas"),
                      Tab(text: "Normas"),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTerminologias(),
            _buildTablas(),
            _buildNormas(),
          ],
        ),
      ),
    );
  }

  Widget _dashboardSuperior(int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dashboardItem("Términos", _terminologias.length.toString()),
          _dashboardItem("Tablas", _tablas.length.toString()),
          _dashboardItem("Normas", _normas.length.toString()),
          _dashboardItem("Total", total.toString()),
        ],
      ),
    );
  }

  Widget _dashboardItem(String titulo, String valor) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: _guinda,
            fontSize: 18.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(
            color: Colors.black.withOpacity(0.70),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  // ==============================
  // TERMINOLOGÍAS VIEW
  // ==============================

  Widget _buildTerminologias() {
    final data = _terminologiasFiltradas;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: TextField(
            controller: _busquedaTerminologiasController,
            style: const TextStyle(color: _negroTexto),
            decoration: InputDecoration(
              hintText: "Buscar dentro de terminologías...",
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.55)),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.black54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.95),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final termino = data[index];
              final titulo = termino["titulo"]!;
              final descripcion = termino["descripcion"]!;
              final isFav = _favoritos.contains(titulo);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withOpacity(0.95),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              color: _guinda,
                              fontSize: 16.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip:
                              isFav ? "Quitar favorito" : "Agregar favorito",
                          onPressed: () {
                            setState(() {
                              if (isFav) {
                                _favoritos.remove(titulo);
                              } else {
                                _favoritos.add(titulo);
                              }
                            });
                          },
                          icon: Icon(
                            isFav
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isFav ? _guindaClaro : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      descripcion,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.82),
                        fontSize: 13.4,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _chipButton(
                          icon: Icons.copy_rounded,
                          label: "Copiar",
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: "$titulo\n\n$descripcion"),
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Copiado: $titulo"),
                                backgroundColor: _guindaClaro,
                              ),
                            );
                          },
                        ),
                        _chipButton(
                          icon: Icons.share_rounded,
                          label: "Compartir",
                          onTap: () {
                            Share.share("$titulo\n\n$descripcion");
                          },
                        ),
                        _chipButton(
                          icon: Icons.history_rounded,
                          label: "Historial",
                          onTap: () {
                            setState(() {
                              if (!_historial.contains(titulo)) {
                                _historial.add(titulo);
                              }
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Guardado en historial: $titulo"),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chipButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: _crema.withOpacity(0.70),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: _guinda),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.black.withOpacity(0.82),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // TABLAS VIEW (placeholder)
  // ==============================
  Widget _buildTablas() {
    final data = _tablasFiltradas;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120, top: 12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final tabla = data[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.95),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tabla["titulo"]!,
                style: const TextStyle(
                  color: _guinda,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  tabla["asset"]!,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              _chipButton(
                icon: Icons.download_rounded,
                label: "Guardar imagen",
                onTap: () => _guardarImagenAsset(
                  tabla["asset"]!,
                  "${tabla["titulo"]}.jpg",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // NORMAS VIEW (placeholder)
  // ==============================
  Widget _buildNormas() {
    final data = _normasFiltradas;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: TextField(
            controller: _busquedaNormasController,
            style: const TextStyle(color: _negroTexto),
            decoration: InputDecoration(
              hintText: "Buscar dentro de normas...",
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.55)),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.black54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.95),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final norma = data[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withOpacity(0.95),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      norma["titulo"]!,
                      style: const TextStyle(
                        color: _guinda,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        norma["asset"]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _chipButton(
                      icon: Icons.download_rounded,
                      label: "Guardar imagen",
                      onTap: () => _guardarImagenAsset(
                        norma["asset"]!,
                        "${norma["titulo"]}.png",
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
