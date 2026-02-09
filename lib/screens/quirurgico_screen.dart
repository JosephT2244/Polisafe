/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:async';

import 'package:flutter/material.dart';
import '../../../models/paes_historial.dart';
import '../../../services/paes_historial_service.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

class QuirurgicoScreen extends StatefulWidget {
  const QuirurgicoScreen({super.key});

  @override
  State<QuirurgicoScreen> createState() => _QuirurgicoScreenState();
}

class _QuirurgicoScreenState extends State<QuirurgicoScreen> {

  // Controllers
  final TextEditingController tecnicaCtrl = TextEditingController();
  final TextEditingController instrumentalCtrl = TextEditingController();
  final TextEditingController bultoCtrl = TextEditingController();
  final TextEditingController tiempoCtrl = TextEditingController();

  // Debounce timer for global search
  Timer? _searchDebounce;

  // Lists (state)
  final List<String> tecnicas = [];
  final List<String> instrumentos = [];
  final List<String> bultos = [];
  final List<String> tiempos = [];

  // Submenu
  int selectedSubMenu = 0;

  // Global search (actual usado para filtrar: solo se actualiza tras debounce)
  String globalSearch = '';

  // UI states
  bool showDashboard = true;

  // Suggestions
  final List<String> sugerenciasTecnicas = [
    'Incisión',
    'Sutura',
    'Resección',
    'Lavado quirúrgico',
    'Hemostasia',
    'Cierre por planos',
    'Disección',
    'Anastomosis',
    'Drenaje quirúrgico',
  ];

  final List<String> sugerenciasInstrumentos = [
    'Bisturí',
    'Pinzas',
    'Tijeras',
    'Portaagujas',
    'Separadores',
    'Aspirador',
    'Electrobisturí',
    'Pinza Kelly',
    'Pinza Mosquito',
  ];

  final List<String> sugerenciasBultos = [
    'Kit Básico',
    'Gasas',
    'Guantes',
    'Campo estéril',
    'Bulto de laparotomía',
    'Bulto de sutura',
    'Bulto de cesárea',
  ];

  final List<String> sugerenciasTiempos = [
    'Preoperatorio',
    'Intraoperatorio',
    'Postoperatorio',
    'Corte / Incisión',
    'Hemostasia',
    'Disección',
    'Exposición',
    'Sutura',
  ];

  // Submenus
  final List<String> subMenus = [
    'Instrumental',
    'Bultos quirúrgicos',
    'Tiempos quirúrgicos',
    'Registro',
    'Manual / PDF',
  ];

  // Checklist quirófano real (estado)
  final Map<String, bool> checklistItems = {
    "Lavado quirúrgico realizado": false,
    "Campos estériles colocados": false,
    "Instrumental completo": false,
    "Gasas contadas": false,
    "Material de sutura listo": false,
    "Aspirador funcionando": false,
    "Electrobisturí probado": false,
    "Paciente identificado": false,
    "Checklist OMS completado": false,
    "Monitoreo conectado": false,
    "Oxígeno listo": false,
    "Soluciones listas": false,
  };

  // Notificador para evitar rebuilds globales al cambiar checklist
  late final ValueNotifier<Map<String, bool>> checklistNotifier;

  // SCROLL / VISIBILITY CONTROLS
  late final ScrollController _scrollController;
  double _lastOffset = 0.0;
  final ValueNotifier<bool> _fabVisible = ValueNotifier<bool>(true);

  /*──────────────────────── INSTRUMENTAL POR SECCIONES ────────────────────────*/
  final Map<String, List<Map<String, String>>> instrumentalSecciones = {
    "Pinzas": [
      {"nombre": "Pinzas para campos de Backhaus", "img": "backhaus.png"},
      {"nombre": "Pinzas de Disección", "img": "pinzas_diseccion.png"},
      {"nombre": "Pinzas de Disección con Dientes", "img": "pinzas_diseccion_dientes.png"},
      {"nombre": "Pinzas de Disección Simples", "img": "pinzas_diseccion_simples.png"},
      {"nombre": "Pinzas de Disección de Debakey", "img": "pinzas_diseccion_debakey.png"},
      {"nombre": "Pinzas de Disección Rusas", "img": "pinzas_diseccion_rusas.png"},
      {"nombre": "Pinzas hemostáticas Kelly curvas", "img": "kelly_curvas.png"},
      {"nombre": "Pinza Mosquito rectas", "img": "mosquito_rectas.png"},
      {"nombre": "Pinzas Rochester Pean", "img": "rochester_pean.png"},
      {"nombre": "Pinzas Allis", "img": "allis.png"},
      {"nombre": "Pinzas de Mixter", "img": "mixter.png"},
      {"nombre": "Pinzas Satinsky", "img": "satinsky.png"},
      {"nombre": "Pinzas Collin Duval", "img": "collin_duval.png"},
      {"nombre": "Pinzas Kocher", "img": "kocher.png"},
      {"nombre": "Pinzas Portaesponja de Foerster", "img": "foerster.png"},
      {"nombre": "Pinzas Babcock", "img": "babcock.png"},
    ],
    "Bisturíes y Mangos": [
      {"nombre": "Mango de bisturí #3 largo", "img": "mango_bisturi_3.png"},
      {"nombre": "Hoja de bisturí #10", "img": "hoja_10.png"},
      {"nombre": "Hoja de bisturí #20", "img": "hoja_20.png"},
      {"nombre": "Hoja de bisturí #11", "img": "hoja_11.png"},
      {"nombre": "Mango de bisturí #4", "img": "mango_bisturi_4.png"},
    ],
    "Tijeras": [
      {"nombre": "Tijeras de Mayo rectas", "img": "mayo_rectas.png"},
      {"nombre": "Tijeras de Mayo curvas", "img": "mayo_curvas.png"},
      {"nombre": "Tijeras de Metzembaum", "img": "metzembaum.png"},
      {"nombre": "Tijeras para Vendajes de Lister", "img": "lister.png"},
    ],
    "Separadores": [
      {"nombre": "Separador Richardson", "img": "richardson.png"},
      {"nombre": "Separador Deaver", "img": "deaver.png"},
      {"nombre": "Separador Gelpi", "img": "gelpi.png"},
      {"nombre": "Separador Senn", "img": "senn.png"},
      {"nombre": "Separador Volkman", "img": "volkman.png"},
    ],
    "Portaagujas": [
      {"nombre": "Portaagujas Mayo-Hegar", "img": "mayo_hegar.png"},
      {"nombre": "Portaagujas Gastroviego", "img": "gastroviejo.png"},
      {"nombre": "Portaagujas Mathieu", "img": "mathieu.png"},
    ],
    "Aspiradores": [
      {"nombre": "Aspirador Yankauer", "img": "yankauer.png"},
      {"nombre": "Aspirador Frazier", "img": "frazier.png"},
      {"nombre": "Cánula de aspiración Poole", "img": "poole.png"},
    ],
    "Material de apoyo": [
      {"nombre": "Lápiz Electroquirúrgico", "img": "lapiz_electroquirurgico.png"},
      {"nombre": "Engrapadora de Piel", "img": "engrapadora_piel.png"},
    ],
  };

  /*──────────────────────── BULTOS QUIRÚRGICOS POR SECCIONES ────────────────────────*/
  final Map<String, List<Map<String, String>>> bultosSecciones = {
    "Ortopedia": [
      {"nombre": "Reducción y Fijación de Fracturas", "img": "reduccion_fijacion_fracturas.png"},
      {"nombre": "Artroplastia", "img": "artroplastia.png"},
      {"nombre": "Artroscopia de Rodilla", "img": "artroscopia_rodilla.png"},
    ],
    "Oftalmología": [
      {"nombre": "Facoemulsificación", "img": "facoemulsificacion.png"},
    ],
    "Urología": [
      {"nombre": "Resección Transuretral de Próstata", "img": "reseccion_transuretral_prostata.png"},
    ],
    "Otorrino": [
      {"nombre": "Amigdalectomía", "img": "amigdalectomia.png"},
    ],
    "Cirugía General": [
      {"nombre": "Colecistectomía", "img": "colecistectomia.png"},
      {"nombre": "Apendicectomía", "img": "apendicectomia.png"},
      {"nombre": "Laparotomia Exploradora", "img": "laparotomia_exploradora.png"},
      {"nombre": "Hernioplastia", "img": "hernioplastia.png"},
      {"nombre": "Hemorroidectomía", "img": "hemorroidectomia.png"},
    ],
    "Ginecología y Obstetricia": [
      {"nombre": "Cesárea", "img": "cesarea.png"},
      {"nombre": "Oclusión Tubaria Bilateral", "img": "oclusion_tubaria_bilateral.png"},
      {"nombre": "Histerectomía", "img": "histerectomia.png"},
      {"nombre": "Legrado Uterino Instrumental (LUI)", "img": "legrado_uterino_lui.png"},
      {"nombre": "Quistectomía de ovario", "img": "quistectomia_ovario.png"},
    ],
    "Procedimientos Especiales": [
      {"nombre": "Lavado Quirúrgico", "img": "lavado_quirurgico.png"},
      {"nombre": "Desbridamiento de Pie Diabético", "img": "desbridamiento_pie_diabetico.png"},
      {"nombre": "Cirugía Bariátrica", "img": "cirugia_bariatrica.png"},
    ],
  };

  /*──────────────────────── TIEMPOS QUIRÚRGICOS ────────────────────────*/
  final List<Map<String, String>> tiemposQuirurgicos = [
    {"nombre": "Corte / Incisión", "img": "Corte_Incisión.png"},
    {"nombre": "Hemostasia", "img": "Hemostasia.png"},
    {"nombre": "Exposición", "img": "Exposición.png"},
    {"nombre": "Disección", "img": "Disección.png"},
    {"nombre": "Sutura", "img": "Sutura.png"},
  ];

  static const Color creamColor = Color(0xFFF8E8D4);
  static const Color darkPurple = Color(0xFF660033);

  @override
  void initState() {
    super.initState();
    checklistNotifier = ValueNotifier<Map<String, bool>>(Map.from(checklistItems));

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    tecnicaCtrl.dispose();
    instrumentalCtrl.dispose();
    bultoCtrl.dispose();
    tiempoCtrl.dispose();
    _searchDebounce?.cancel();
    checklistNotifier.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabVisible.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position.pixels;

    // Evitar reacciones en rebote (scroll negativo) y pequeñas oscilaciones
    if (pos < 0) {
      _lastOffset = pos;
      return;
    }

    final delta = pos - _lastOffset;

    // Hide FAB when scrolling down fast, show when scrolling up fast
    if (delta > 12 && _fabVisible.value == true) {
      _fabVisible.value = false;
    } else if (delta < -12 && _fabVisible.value == false) {
      _fabVisible.value = true;
    }

    _lastOffset = pos;
  }

  /*──────────────────── UTILIDAD: SNACKBAR ────────────────────*/
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /*──────────────────── LIMPIAR TODO ────────────────────*/
  void _clearAll() {
    setState(() {
      tecnicas.clear();
      instrumentos.clear();
      bultos.clear();
      tiempos.clear();

      tecnicaCtrl.clear();
      instrumentalCtrl.clear();
      bultoCtrl.clear();
      tiempoCtrl.clear();

      globalSearch = '';
      checklistItems.updateAll((key, value) => false);
      checklistNotifier.value = Map.from(checklistItems);
    });

    _snack("Todo fue limpiado correctamente.");
  }

  /*──────────────────── GUARDAR HISTORIAL ────────────────────*/
  void _guardarQuirurgico() {
    final buffer = StringBuffer();
    buffer.writeln('Área Quirúrgica:');

    buffer.writeln('\nTécnicas:');
    for (var t in tecnicas) {
      buffer.writeln('- $t');
    }

    buffer.writeln('\nInstrumental:');
    for (var i in instrumentos) {
      buffer.writeln('- $i');
    }

    buffer.writeln('\nBultos quirúrgicos:');
    for (var b in bultos) {
      buffer.writeln('- $b');
    }

    buffer.writeln('\nTiempos quirúrgicos:');
    for (var ti in tiempos) {
      buffer.writeln('- $ti');
    }

    buffer.writeln('\nChecklist quirófano:');
    checklistItems.forEach((key, value) {
      buffer.writeln('- ${value ? "[OK]" : "[FALTA]"} $key');
    });

    PaesHistorialService.agregar(
      PaesHistorialItem(
        etapa: PaesEtapa.quirurgico,
        contenido: buffer.toString(),
        fecha: DateTime.now(),
      ),
    );

    _snack("Área quirúrgica guardada en historial.");
  }

  /*──────────────────── VER HISTORIAL ────────────────────*/
  void _verHistorial() {
    final historial = PaesHistorialService.obtenerPorEtapa(PaesEtapa.quirurgico);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Historial Área Quirúrgica'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay registros guardados.')
              : ListView.builder(
                  itemCount: historial.length,
                  itemBuilder: (_, index) {
                    final item = historial[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          "Registro ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.contenido),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar registro',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text('¿Desea eliminar este registro?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              setState(() {
                                PaesHistorialService.eliminar(item);
                              });

                              Navigator.pop(context);
                              _verHistorial();
                            }
                          },
                        ),
                      ),
                    );
                  },
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

  /*──────────────────── PDF IMAGE LOADER ────────────────────*/
  Future<pw.MemoryImage?> _loadPdfImage(String path) async {
    try {
      final bytes = await rootBundle.load(path);
      final data = bytes.buffer.asUint8List();
      return pw.MemoryImage(data);
    } catch (_) {
      return null;
    }
  }

  /*──────────────────── EXPORTAR PDF MANUAL PRO ────────────────────*/
  Future<void> _exportarPDFManual() async {
    final pdf = pw.Document();

    final portadaImg = await _loadPdfImage("assets/images/quirurgico/portada.png");

    final totalInstrumentos = instrumentos.length;
    final totalBultos = bultos.length;
    final totalTiempos = tiempos.length;
    final totalTecnicas = tecnicas.length;

    final checklistOk = checklistItems.values.where((v) => v).length;
    final checklistTotal = checklistItems.length;

    pw.Widget buildTitle(String t) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(
          t,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF660033),
          ),
        ),
      );
    }

    pw.Widget buildList(List<String> items) {
      if (items.isEmpty) {
        return pw.Text("—", style: pw.TextStyle(color: PdfColors.grey600));
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((e) => pw.Bullet(text: e)).toList(),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF660033),
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 62,
                  height: 62,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(14),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      "MAN",
                      style: const pw.TextStyle(
                        fontSize: 22,
                        color: PdfColor.fromInt(0xFF660033),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 14),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "MANUAL QUIRÓFANO",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Área Quirúrgica - Instrumental y Bultos",
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Generado automáticamente por PoliSafe",
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          if (portadaImg != null)
            pw.Container(
              height: 200,
              child: pw.ClipRRect(
                horizontalRadius: 16,
                verticalRadius: 16,
                child: pw.Image(portadaImg, fit: pw.BoxFit.cover),
              ),
            ),
          pw.SizedBox(height: 16),
          buildTitle("Mini Dashboard"),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Bullet(text: "Técnicas registradas: $totalTecnicas"),
                pw.Bullet(text: "Instrumental seleccionado: $totalInstrumentos"),
                pw.Bullet(text: "Bultos seleccionados: $totalBultos"),
                pw.Bullet(text: "Tiempos quirúrgicos: $totalTiempos"),
                pw.Bullet(text: "Checklist completado: $checklistOk / $checklistTotal"),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          buildTitle("Checklist de Quirófano"),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: checklistItems.entries.map((e) {
                return pw.Row(
                  children: [
                    pw.Text(e.value ? "☑" : "☐", style: const pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(e.key, style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          pw.SizedBox(height: 16),
          buildTitle("Técnicas"),
          buildList(tecnicas),
          buildTitle("Instrumental Seleccionado"),
          buildList(instrumentos),
          buildTitle("Bultos Quirúrgicos Seleccionados"),
          buildList(bultos),
          buildTitle("Tiempos Quirúrgicos"),
          buildList(tiempos),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Text(
              "Documento generado automáticamente. Recomendación: validar instrumental y conteo de gasas antes de iniciar procedimiento.",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      _snack('Error al generar PDF: $e');
    }
  }

  /*──────────────────── MINI DASHBOARD UI ────────────────────*/
  Widget _miniDashboard() {
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: checklistNotifier,
      builder: (_, checklistMap, __) {
        final checklistOk = checklistMap.values.where((v) => v).length;

        if (!showDashboard) return const SizedBox.shrink();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _dashCard('Técnicas', tecnicas.length, Icons.science),
            _dashCard('Instrumental', instrumentos.length, Icons.build),
            _dashCard('Bultos', bultos.length, Icons.shopping_bag),
            _dashCard('Tiempos', tiempos.length, Icons.timer),
            _dashCard('Checklist', checklistOk, Icons.check_circle, color: Colors.green),
            _dashCard(
              'Manual PDF',
              0,
              Icons.picture_as_pdf,
              color: Colors.redAccent,
              onTap: _exportarPDFManual,
            ),
          ],
        );
      },
    );
  }

  Widget _dashCard(String title, int count, IconData icon, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 120,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color ?? darkPurple, size: 34),
                const SizedBox(height: 8),
                if (count != 0)
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*──────────────────── SUBMENU CHIPS ────────────────────*/
  Widget _subMenuChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        key: const PageStorageKey('submenus_chips'),
        scrollDirection: Axis.horizontal,
        itemCount: subMenus.length,
        itemBuilder: (context, index) {
          final selected = index == selectedSubMenu;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(subMenus[index]),
              selected: selected,
              selectedColor: darkPurple,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                if (selectedSubMenu != index) {
                  setState(() => selectedSubMenu = index);
                }
              },
            ),
          );
        },
      ),
    );
  }

  /*──────────────────── BUSCADOR GLOBAL (con debounce) ────────────────────*/
  Widget _globalSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        onChanged: _onGlobalSearchChanged,
        decoration: InputDecoration(
          hintText: "Buscar en todo (instrumental, bultos, tiempos)...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _onGlobalSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final v = value.trim().toLowerCase();
      if (v != globalSearch) {
        setState(() {
          globalSearch = v;
        });
      }
    });
  }

  /*──────────────────── CARD SECCIÓN ────────────────────*/
  Widget _sectionCard({
    required String title,
    required List<Map<String, String>> items,
    required double aspectRatio,
    required Function(String nombre) onAddToList,
  }) {
    final filtered = globalSearch.isEmpty
        ? items
        : items.where((item) {
            final nombre = item["nombre"]!.toLowerCase();
            return nombre.contains(globalSearch);
          }).toList();

    return Card(
      elevation: 12,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    "${filtered.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const Divider(height: 28),
            if (filtered.isEmpty)
              const Text(
                "No hay resultados con esa búsqueda.",
                style: TextStyle(color: Colors.grey),
              )
            else
              // Replaced inner ListView.builder(shrinkWrap:true) with Column to avoid nested scroll re-measure issues
              Column(
                children: filtered.map((item) {
                  final nombre = item["nombre"]!;
                  final img = item["img"]!;
                  final assetPath = "assets/images/quirurgico/$img";

                  return RepaintBoundary(
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _openImageFullScreen(assetPath),
                              child: Hero(
                                tag: assetPath,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    child: AspectRatio(
                                      aspectRatio: aspectRatio,
                                      child: Image.asset(
                                        assetPath,
                                        fit: BoxFit.cover,
                                        cacheWidth: 600, // slightly larger cache to reduce re-layouts
                                        filterQuality: FilterQuality.low,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.broken_image, size: 48),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => onAddToList(nombre),
                                icon: const Icon(Icons.add),
                                label: const Text("Agregar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: creamColor,
                                  foregroundColor: darkPurple,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /*──────────────────── INSTRUMENTAL SLIVER ────────────────────*/
  Widget _instrumentalSliver() {
    final entries = instrumentalSecciones.entries.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return _sectionCard(
            title: entry.key,
            items: entry.value,
            aspectRatio: 12.6 / 18.8,
            onAddToList: (nombre) {
              if (!instrumentos.contains(nombre)) {
                setState(() {
                  instrumentos.add(nombre);
                });
                _snack("$nombre agregado a Instrumental.");
              }
            },
          );
        },
        childCount: entries.length,
      ),
    );
  }

  /*──────────────────── BULTOS SLIVER ────────────────────*/
  Widget _bultosSliver() {
    final entries = bultosSecciones.entries.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return _sectionCard(
            title: entry.key,
            items: entry.value,
            aspectRatio: 21.59 / 27.94,
            onAddToList: (nombre) {
              if (!bultos.contains(nombre)) {
                setState(() {
                  bultos.add(nombre);
                });
                _snack("$nombre agregado a Bultos.");
              }
            },
          );
        },
        childCount: entries.length,
      ),
    );
  }

  /*──────────────────── TIEMPOS SLIVER ────────────────────*/
  Widget _tiemposSliver() {
    return SliverToBoxAdapter(
      child: _sectionCard(
        title: "Tiempos quirúrgicos",
        items: tiemposQuirurgicos,
        aspectRatio: 13.2 / 19,
        onAddToList: (nombre) {
          if (!tiempos.contains(nombre)) {
            setState(() {
              tiempos.add(nombre);
            });
            _snack("$nombre agregado a Tiempos.");
          }
        },
      ),
    );
  }

  /*──────────────────── CHECKLIST VIEW (sin ListView interno) ────────────────────*/
  Widget _checklistView() {
    return Card(
      elevation: 12,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Checklist Quirófano Real",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Marca cada punto como completado antes de exportar el manual.",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 28),
            ValueListenableBuilder<Map<String, bool>>(
              valueListenable: checklistNotifier,
              builder: (_, map, __) {
                final entries = map.entries.toList();

                return Column(
                  children: entries.map((entry) {
                    return SwitchListTile(
                      value: entry.value,
                      activeThumbColor: darkPurple,
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        entry.value ? "Completado" : "Falta",
                        style: TextStyle(
                          color: entry.value ? Colors.green : Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (val) {
                        checklistItems[entry.key] = val;
                        checklistNotifier.value = Map.from(checklistItems);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /*──────────────────── COLLAPSIBLE SECTION ────────────────────*/
  Widget _collapsibleSection({
    required String title,
    required TextEditingController controller,
    required List<String> items,
    required List<String> suggestions,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    final filteredItems = globalSearch.isEmpty
        ? items
        : items.where((e) => e.toLowerCase().contains(globalSearch)).toList();

    final filteredSuggestions = suggestions.where((e) => e.toLowerCase().contains(controller.text.toLowerCase())).toList();

    return Card(
      elevation: 10,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        key: PageStorageKey('expansion_$title'), // preserve expansion state
        collapsedIconColor: darkPurple,
        iconColor: darkPurple,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Agregar $title',
                    hintText: 'Ej: ${suggestions.isNotEmpty ? suggestions.first : ''}',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle, color: darkPurple),
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          onAdd(controller.text.trim());
                          controller.clear();
                          setState(() {});
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                if (controller.text.isNotEmpty && filteredSuggestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: filteredSuggestions
                          .map((s) => ActionChip(
                                label: Text(s),
                                backgroundColor: Colors.purple[50],
                                onPressed: () {
                                  onAdd(s);
                                  controller.clear();
                                  setState(() {});
                                },
                              ))
                          .toList(),
                    ),
                  ),

                const SizedBox(height: 12),

                if (filteredItems.isEmpty)
                  const Text('—', style: TextStyle(color: Colors.grey))
                else
                  Column(
                    children: filteredItems
                        .map(
                          (e) => Card(
                            elevation: 3,
                            shadowColor: Colors.black12,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle_outline, color: darkPurple),
                              title: Text(e),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => onRemove(e),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*──────────────────── REGISTRO VIEW ────────────────────*/
  Widget _registroView() {
    return Column(
      children: [
        _miniDashboard(),
        const SizedBox(height: 18),
        _checklistView(),
        const SizedBox(height: 18),

        _collapsibleSection(
          title: 'Técnicas',
          controller: tecnicaCtrl,
          items: tecnicas,
          suggestions: sugerenciasTecnicas,
          onAdd: (v) {
            if (!tecnicas.contains(v)) {
              setState(() {
                tecnicas.add(v);
              });
            }
          },
          onRemove: (v) => setState(() => tecnicas.remove(v)),
        ),

        _collapsibleSection(
          title: 'Instrumental',
          controller: instrumentalCtrl,
          items: instrumentos,
          suggestions: sugerenciasInstrumentos,
          onAdd: (v) {
            if (!instrumentos.contains(v)) {
              setState(() {
                instrumentos.add(v);
              });
            }
          },
          onRemove: (v) => setState(() => instrumentos.remove(v)),
        ),

        _collapsibleSection(
          title: 'Bultos',
          controller: bultoCtrl,
          items: bultos,
          suggestions: sugerenciasBultos,
          onAdd: (v) {
            if (!bultos.contains(v)) {
              setState(() {
                bultos.add(v);
              });
            }
          },
          onRemove: (v) => setState(() => bultos.remove(v)),
        ),

        _collapsibleSection(
          title: 'Tiempos',
          controller: tiempoCtrl,
          items: tiempos,
          suggestions: sugerenciasTiempos,
          onAdd: (v) {
            if (!tiempos.contains(v)) {
              setState(() {
                tiempos.add(v);
              });
            }
          },
          onRemove: (v) => setState(() => tiempos.remove(v)),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _guardarQuirurgico,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: creamColor,
                  foregroundColor: darkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: creamColor,
                  foregroundColor: darkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /*──────────────────── MANUAL PDF VIEW ────────────────────*/
  Widget _manualPdfView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _miniDashboard(),
        const SizedBox(height: 18),

        Card(
          elevation: 12,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Exportación Completa a PDF",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Este PDF se genera como un manual quirúrgico profesional, con dashboard, checklist y listas ordenadas.",
                  style: TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: _exportarPDFManual,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Exportar Manual PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: creamColor,
                    foregroundColor: darkPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Consejo: Completa checklist y agrega instrumental antes de exportar.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  /*──────────────────── CONTENIDO SEGÚN SUBMENU (SLIVERS) ────────────────────*/
  Widget _contenidoSliver() {
    switch (selectedSubMenu) {
      case 0:
        return _instrumentalSliver();
      case 1:
        return _bultosSliver();
      case 2:
        return _tiemposSliver();
      case 3:
        return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 8), child: _registroView()));
      case 4:
        return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 8), child: _manualPdfView()));
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  /*──────────────────── FLOATING BUTTON MENU ────────────────────*/
  Widget _floatingMenu() {
    return ValueListenableBuilder<bool>(
      valueListenable: _fabVisible,
      builder: (context, visible, _) {
        return AnimatedScale(
          scale: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            backgroundColor: creamColor,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.save, color: darkPurple),
                        title: const Text("Guardar registro"),
                        onTap: () {
                          Navigator.pop(context);
                          _guardarQuirurgico();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                        title: const Text("Exportar Manual PDF"),
                        onTap: () {
                          Navigator.pop(context);
                          _exportarPDFManual();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.cleaning_services, color: Colors.blueGrey),
                        title: const Text("Limpiar todo"),
                        onTap: () {
                          Navigator.pop(context);
                          _clearAll();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history, color: Colors.orange),
                        title: const Text("Ver historial"),
                        onTap: () {
                          Navigator.pop(context);
                          _verHistorial();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Icon(Icons.menu, color: darkPurple),
          ),
        );
      },
    );
  }

  /*──────────────────── OPEN IMAGE FULLSCREEN ────────────────────*/
  void _openImageFullScreen(String assetPath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Hero(
              tag: assetPath,
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      cacheWidth: 1200,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, color: Colors.white, size: 64);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _headerWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkPurple,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.local_hospital, size: 50, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Área Quirúrgica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Instrumental, bultos y tiempos quirúrgicos',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => showDashboard = !showDashboard),
            icon: Icon(
              showDashboard ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            tooltip: 'Mostrar/Ocultar dashboard',
          ),
          IconButton(
            onPressed: _verHistorial,
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Ver historial',
          ),
        ],
      ),
    );
  }

  /*──────────────────── BUILD ────────────────────*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingMenu(),
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        controller: _scrollController,
        // Use clamping to avoid large bounce/rebound jumps
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _headerWidget(),
                  const SizedBox(height: 16),
                  _globalSearchBar(),
                  _subMenuChips(),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _contenidoSliver(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 90),
          ),
        ],
      ),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
