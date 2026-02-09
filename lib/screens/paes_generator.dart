/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ═══════════════════════════════════════*/

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../models/paes_model.dart' as model;
import '../models/paes_historial.dart';
import '../utils/paes_pdf_generator.dart';

import '../../services/paes_historial_service.dart';

// SERVICES REALES (JSON)
import '../../services/nanda_service.dart';
import '../../services/nic_service.dart';
import '../../services/noc_service.dart';

class PaesGeneratorScreen extends StatefulWidget {
  const PaesGeneratorScreen({super.key});

  @override
  State<PaesGeneratorScreen> createState() => _PaesGeneratorScreenState();
}

class _PaesGeneratorScreenState extends State<PaesGeneratorScreen> {
  int _currentStep = 0;

  bool _catalogosCargados = false;
  bool _cargandoCatalogos = false;
  String? _errorCatalogos;

  // ────────── Datos del paciente ──────────
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Masculino';
  // **Nuevo** controlador para especificar sexo cuando se elige "Otro"
  final _genderOtherController = TextEditingController();

  DateTime? _birthDate;
  final _expNumberController = TextEditingController();
  final _serviceController = TextEditingController();
  final _bedController = TextEditingController();
  DateTime _valuationDate = DateTime.now();

  // ────────── Datos clínicos ──────────
  final _diagnosisController = TextEditingController();
  final _reasonController = TextEditingController();
  final _antecedentsPathController = TextEditingController();
  final _antecedentsNonPathController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _vitalsController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _familySocialController = TextEditingController();

  // ────────── Signos vitales estructurados ──────────
  final _bloodTypeController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _abdominalCircController = TextEditingController();

  // ────────── Escalas de valoración ──────────
  double _evaPain = 0;
  int _downtonFall = 0;
  int _braden = 0;
  int _glasgow = 15;

  // ────────── Valoración ──────────
  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _generalStateController = TextEditingController();
  final _mentalStateController = TextEditingController();
  // Reemplazamos el TextField libre por opciones predefinidas + "Otro"
  String _consciousnessSelected = 'Alerta';
  final _consciousnessOtherController = TextEditingController();
  final _oxygenationController = TextEditingController();
  final _feedingController = TextEditingController();
  final _eliminationController = TextEditingController();
  final _mobilityController = TextEditingController();
  final _hygieneController = TextEditingController();
  final _emotionalController = TextEditingController();
  final _adultDoseController = TextEditingController();
  final _pediatricDoseController = TextEditingController();
  final _bmiController = TextEditingController();
  final _pamController = TextEditingController();
  final _dripController = TextEditingController();
  final _insensibleLossesController = TextEditingController();

  // ────────── Problemas detectados ──────────
  final List<String> _actualProblems = [];
  final _actualProblemController = TextEditingController();
  final List<String> _potentialProblems = [];
  final _potentialProblemController = TextEditingController();

  // ────────── Diagnóstico NANDA (REAL) ──────────
  final TextEditingController _nandaSearchCtrl = TextEditingController();
  final TextEditingController _nandaCodeCtrl = TextEditingController();
  final TextEditingController _nandaLabelCtrl = TextEditingController();
  final TextEditingController _nandaDefinitionCtrl = TextEditingController();
  // Nuevos campos para mostrar dominio y clase
  final TextEditingController _nandaDomainCtrl = TextEditingController();
  final TextEditingController _nandaClassCtrl = TextEditingController();

  List<Map<String, dynamic>> _resultadosNanda = [];
  bool _searchingNanda = false;

  String? _nandaSelectedCode;
  String? _nandaSelectedLabel;

  final _nandaEtiologyController = TextEditingController();
  final _nandaSignsController = TextEditingController();
  String _priority = 'Alta';

  // ────────── NOC / NIC (REAL) ──────────
  final TextEditingController _nocSearchCtrl = TextEditingController();
  final TextEditingController _nicSearchCtrl = TextEditingController();

  List<Map<String, dynamic>> _resultadosNoc = [];
  List<Map<String, dynamic>> _resultadosNic = [];

  bool _searchingNoc = false;
  bool _searchingNic = false;

  List<String> _nocObjectives = [];
  List<String> _nicInterventions = [];

  // ────────── Ejecución, Evaluación y Registros ──────────
  final _executionController = TextEditingController();
  final _evaluationController = TextEditingController();
  final _recordsController = TextEditingController();
  final _educationController = TextEditingController();
  final _contingencyController = TextEditingController();
  final _nursingNotesController = TextEditingController();
  final _dischargeCriteriaController = TextEditingController();

  // ────────── Campos Generals por etapa ──────────
  final _valoracionContentController = TextEditingController();
  final _diagnosticoContentController = TextEditingController();
  final _planificacionContentController = TextEditingController();
  final _ejecucionContentController = TextEditingController();
  final _evaluacionContentController = TextEditingController();

  // ────────── Firma ──────────
  final _signatureController = TextEditingController();
  String _category = 'Enfermero/a';
  String _shift = 'Matutino';

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  // ==========================================================
  // CARGA DE CATÁLOGOS NANDA/NIC/NOC (UNA SOLA VEZ)
  // ==========================================================
  Future<void> _cargarCatalogos() async {
    if (_catalogosCargados || _cargandoCatalogos) return;

    setState(() {
      _cargandoCatalogos = true;
      _errorCatalogos = null;
    });

    try {
      await Future.wait([
        NandaService.load(),
        NicService.load(),
        NocService.load(),
      ]);

      if (!mounted) return;

      setState(() {
        _catalogosCargados = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorCatalogos = 'Error al cargar catálogos NANDA/NIC/NOC: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _cargandoCatalogos = false;
      });
    }
  }

  // ==========================================================
  // UTILIDADES
  // ==========================================================
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

  void _addToList(TextEditingController controller, List<String> list) {
    if (controller.text.isNotEmpty) {
      setState(() {
        list.add(controller.text);
        controller.clear();
      });
    }
  }

  void _removeFromList(List<String> list, int index) {
    setState(() => list.removeAt(index));
  }

  // ==========================================================
  // BUSCAR NANDA REAL
  // ==========================================================
  Future<void> _searchNanda(String query) async {
    if (!_catalogosCargados) return;
    if (_searchingNanda) return;

    _searchingNanda = true;

    try {
      final maybe = NandaService.search(query);

      List<Map<String, dynamic>> res;

      if (maybe is Future) {
        final awaited = await maybe;
        res = List<Map<String, dynamic>>.from(awaited);
      } else {
        res = List<Map<String, dynamic>>.from(maybe);
      }

      if (!mounted) return;

      setState(() {
        _resultadosNanda = res;
      });

      if (res.length == 1 && _exactMatchWithQuery(res[0], query)) {
        _selectNanda(res[0]);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _resultadosNanda = []);
    } finally {
      _searchingNanda = false;
    }
  }

  void _selectNanda(Map<String, dynamic> n) {
    _nandaSelectedCode = (n['codigo'] ?? '').toString();
    _nandaSelectedLabel = (n['etiqueta'] ?? '').toString();

    _nandaCodeCtrl.text = _nandaSelectedCode ?? '';
    _nandaLabelCtrl.text = _nandaSelectedLabel ?? '';
    _nandaDefinitionCtrl.text = (n['definicion'] ?? '').toString();

    // rellenar dominio y clase si vienen en el JSON
    _nandaDomainCtrl.text = (n['dominio'] ?? '').toString();
    _nandaClassCtrl.text = (n['clase'] ?? '').toString();

    setState(() {
      _resultadosNanda = [];
      _nandaSearchCtrl.clear();
    });

    _autoSuggestFromNandaCode(_nandaSelectedCode ?? '');
  }

  // ==========================================================
  // SUGERENCIA AUTOMÁTICA REAL (NIC + NOC) POR NANDA CODE
  // ==========================================================
  void _autoSuggestFromNandaCode(String nandaCode) {
    if (nandaCode.trim().isEmpty) return;

    try {
      final nicList = NicService.byNanda(nandaCode);
      final nocList = NocService.byNanda(nandaCode);

      setState(() {
        _nicInterventions =
            nicList.map((e) => "${e['codigo']} - ${e['etiqueta']} (${e['dominio'] ?? ''} / ${e['clase'] ?? ''})").toList();

        _nocObjectives =
            nocList.map((e) => "${e['codigo']} - ${e['etiqueta']} (${e['dominio'] ?? ''} / ${e['clase'] ?? ''})").toList();
      });
    } catch (_) {}
  }

  // ==========================================================
  // BUSCAR NOC REAL
  // ==========================================================
  Future<void> _searchNoc(String query) async {
    if (!_catalogosCargados) return;
    if (_searchingNoc) return;

    _searchingNoc = true;

    try {
      final maybe = NocService.search(query);

      List<Map<String, dynamic>> res;

      if (maybe is Future) {
        final awaited = await maybe;
        res = List<Map<String, dynamic>>.from(awaited);
      } else {
        res = List<Map<String, dynamic>>.from(maybe);
      }

      if (!mounted) return;

      setState(() {
        _resultadosNoc = res;
      });

      if (res.length == 1 && _exactMatchWithQuery(res[0], query)) {
        final item = res[0];
        final value = "${item['codigo']} - ${item['etiqueta']} (${item['dominio'] ?? ''} / ${item['clase'] ?? ''})";

        setState(() {
          if (!_nocObjectives.contains(value)) {
            _nocObjectives.add(value);
          }
          _resultadosNoc = [];
          _nocSearchCtrl.clear();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _resultadosNoc = []);
    } finally {
      _searchingNoc = false;
    }
  }

  // ==========================================================
  // BUSCAR NIC REAL
  // ==========================================================
  Future<void> _searchNic(String query) async {
    if (!_catalogosCargados) return;
    if (_searchingNic) return;

    _searchingNic = true;

    try {
      final maybe = NicService.search(query);

      List<Map<String, dynamic>> res;

      if (maybe is Future) {
        final awaited = await maybe;
        res = List<Map<String, dynamic>>.from(awaited);
      } else {
        res = List<Map<String, dynamic>>.from(maybe);
      }

      if (!mounted) return;

      setState(() {
        _resultadosNic = res;
      });

      if (res.length == 1 && _exactMatchWithQuery(res[0], query)) {
        final item = res[0];
        final value = "${item['codigo']} - ${item['etiqueta']} (${item['dominio'] ?? ''} / ${item['clase'] ?? ''})";

        setState(() {
          if (!_nicInterventions.contains(value)) {
            _nicInterventions.add(value);
          }
          _resultadosNic = [];
          _nicSearchCtrl.clear();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _resultadosNic = []);
    } finally {
      _searchingNic = false;
    }
  }

  // ==========================================================
  // FECHAS
  // ==========================================================
  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _selectValuationDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _valuationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) setState(() => _valuationDate = picked);
  }

  // ==========================================================
  // FUNCIONES PARA ABRIR EL PDF DEL CATÁLOGO EN UNA PÁGINA
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

  // Abre el PDF de catálogo en la página especificada (1-based)
  Future<void> _openCatalogPdfAtPage(String assetPath, int pageNumber, BuildContext context) async {
    try {
      // Usar el nombre real del asset como filename para evitar sobreescribir siempre el mismo archivo
      final filename = assetPath.split('/').last;
      final path = await _copyAssetPdfToTemp(assetPath, filename);

      // Abrir documento (await para obtener PdfDocument)
      final controller = PdfController(
        document: PdfDocument.openFile(path),
        initialPage: pageNumber,
      );

      // Navegamos a una pantalla con PdfView
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text('Catálogo - $filename')),
          body: PdfView(controller: controller),
        );
      }));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir PDF de catálogo: $e')),
      );
    }
  }

  // ==========================================================
  // GUARDAR + PDF + HISTORIAL
  // ==========================================================
  void _savePaes() async {
    // Parse numéricos
    final double weight = double.tryParse(_weightController.text) ?? 0;
    final double height = double.tryParse(_heightController.text) ?? 0; // m
    final double abdominal =
        double.tryParse(_abdominalCircController.text) ?? 0;
    final int sys = int.tryParse(_systolicController.text) ?? 0;
    final int dia = int.tryParse(_diastolicController.text) ?? 0;
    final int hr = int.tryParse(_heartRateController.text) ?? 0;
    final int rr = int.tryParse(_respiratoryRateController.text) ?? 0;
    final int spo2 = int.tryParse(_spo2Controller.text) ?? 0;
    final double temp = double.tryParse(_temperatureController.text) ?? 0.0;
    final double glucose = double.tryParse(_glucoseController.text) ?? 0.0;

    // Cálculos
    final double bmiCalculated =
        (height > 0) ? (weight / (height * height)) : 0.0;
    final double bsaCalculated = (height > 0 && weight > 0)
        ? sqrt((weight * (height * 100)) / 3600)
        : 0.0; // Mosteller (height en cm)
    final double pamCalculated =
        (sys > 0 && dia > 0) ? ((sys + (2 * dia)) / 3) : 0.0;

    // Si el usuario seleccionó "Otro" para conciencia, tomar el texto especificado
    final consciousnessValue =
        (_consciousnessSelected == 'Otro') ? _consciousnessOtherController.text : _consciousnessSelected;

    // **Uso del sexo especificado si escogió 'Otro'**
    final savedGender = (_gender == 'Otro' && _genderOtherController.text.trim().isNotEmpty)
        ? _genderOtherController.text.trim()
        : _gender;

    final paes = model.PaesModel(
      // Identificación
      patientName: _patientNameController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: savedGender, // <-- aquí usamos savedGender
      birthDate: _birthDate?.toIso8601String() ?? '',
      expediente: _expNumberController.text,
      service: _serviceController.text,
      bed: _bedController.text,
      evaluationDateTime: _valuationDate.toIso8601String(),

      // Datos clínicos generales
      medicalDiagnosis: _diagnosisController.text,
      admissionReason: _reasonController.text,
      personalAntecedents: _antecedentsPathController.text,
      nonPathAntecedents: _antecedentsNonPathController.text,
      allergies: _allergiesController.text,
      medications: _medicationsController.text,
      familySocialAntecedents: _familySocialController.text,

      // Vital signs (texto)
      vitalSigns: '''
TA: ${_systolicController.text}/${_diastolicController.text} mmHg
FC: ${_heartRateController.text} lpm
FR: ${_respiratoryRateController.text} rpm
Temp: ${_temperatureController.text} °C
SpO2: ${_spo2Controller.text} %
Glucosa: ${_glucoseController.text} mg/dL
Circunferencia abdominal: ${_abdominalCircController.text} cm
Tipo de sangre: ${_bloodTypeController.text}
''',

      // Signos vitales estructurados
      temperature: temp,
      heartRate: hr,
      respiratoryRate: rr,
      systolicPressure: sys,
      diastolicPressure: dia,
      spo2: spo2,
      glucose: glucose,

      // Antropometría
      weight: weight,
      height: height,
      abdominalCircumference: abdominal,
      bmi: double.tryParse(_bmiController.text) ?? bmiCalculated,
      bsa: bsaCalculated,

      // Sangre
      bloodType: _bloodTypeController.text,

      // Valoración
      subjectiveData: _subjectiveController.text,
      objectiveData: _objectiveController.text,
      generalState: _generalStateController.text,
      mentalState: _mentalStateController.text,
      consciousnessLevel: consciousnessValue,

      // Escalas
      evaPain: _evaPain.toInt(),
      downtonFallRisk: _downtonFall,
      bradenUlcerRisk: _braden,
      glasgow: _glasgow,

      // Sistemas
      oxygenation: _oxygenationController.text,
      feedingHydration: _feedingController.text,
      elimination: _eliminationController.text,
      mobility: _mobilityController.text,
      hygieneRest: _hygieneController.text,
      emotionalState: _emotionalController.text,

      // Cálculos / dosis
      adultDose: double.tryParse(_adultDoseController.text) ?? 0,
      pediatricDose: double.tryParse(_pediatricDoseController.text) ?? 0,
      pam: double.tryParse(_pamController.text) ?? pamCalculated,
      drip: _dripController.text,
      insensibleLosses: _insensibleLossesController.text,

      // Problemas
      actualProblems: _actualProblems,
      potentialProblems: _potentialProblems,

      // NANDA
      nandaCode: _nandaSelectedCode ?? _nandaCodeCtrl.text,
      nandaLabel: _nandaSelectedLabel ?? _nandaLabelCtrl.text,
      etiology: _nandaEtiologyController.text,
      signsSymptoms: _nandaSignsController.text,
      priority: _priority,

      // NOC / NIC
      nocObjectives: _nocObjectives,
      nicInterventions: _nicInterventions,

      // Ejecución y evaluación
      executionNotes: [_executionController.text],
      nursingNotes: [
        _recordsController.text,
        _nursingNotesController.text,
      ],
      evaluation: _evaluationController.text,

      // Educación y planes
      patientEducation: _educationController.text,
      contingencyPlan: _contingencyController.text,
      dischargeCriteria: _dischargeCriteriaController.text,

      // Firma
      nurseName: _signatureController.text,
      nurseCategory: _category,
      shift: _shift,
      signature: 'Firmado electrónicamente',

      // Contenidos por etapa
      valoracionContent: _valoracionContentController.text,
      diagnosticoContent: _diagnosticoContentController.text,
      planificacionContent: _planificacionContentController.text,
      ejecucionContent: _ejecucionContentController.text,
      evaluacionContent: _evaluacionContentController.text,
    );

    final pdfBytes = await PaesPdfGenerator.generate(paes);

    await Printing.layoutPdf(
      name: "PAES_${paes.patientName}.pdf",
      onLayout: (format) async => pdfBytes,
    );

    final fechaActual = DateTime.now();

    PaesHistorialService.agregar(PaesHistorialItem(
      fecha: fechaActual,
      etapa: PaesEtapa.valoracion,
      contenido: _valoracionContentController.text.isNotEmpty
          ? _valoracionContentController.text
          : "${_subjectiveController.text}\n${_objectiveController.text}",
    ));

    PaesHistorialService.agregar(PaesHistorialItem(
      fecha: fechaActual,
      etapa: PaesEtapa.diagnostico,
      contenido: _diagnosticoContentController.text.isNotEmpty
          ? _diagnosticoContentController.text
          : "${_nandaCodeCtrl.text} - ${_nandaLabelCtrl.text}\nDefinición: ${_nandaDefinitionCtrl.text}\nDominio: ${_nandaDomainCtrl.text}\nClase: ${_nandaClassCtrl.text}\nEtiología: ${_nandaEtiologyController.text}\nSignos: ${_nandaSignsController.text}",
    ));

    PaesHistorialService.agregar(PaesHistorialItem(
      fecha: fechaActual,
      etapa: PaesEtapa.planificacion,
      contenido: _planificacionContentController.text.isNotEmpty
          ? _planificacionContentController.text
          : "Objetivos NOC:\n${_nocObjectives.join('\n')}\n\nIntervenciones NIC:\n${_nicInterventions.join('\n')}",
    ));

    PaesHistorialService.agregar(PaesHistorialItem(
      fecha: fechaActual,
      etapa: PaesEtapa.ejecucion,
      contenido: _ejecucionContentController.text.isNotEmpty
          ? _ejecucionContentController.text
          : _executionController.text,
    ));

    PaesHistorialService.agregar(PaesHistorialItem(
      fecha: fechaActual,
      etapa: PaesEtapa.evaluacion,
      contenido: _evaluacionContentController.text.isNotEmpty
          ? _evaluacionContentController.text
          : _evaluationController.text,
    ));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PAES generado y guardado en historial')),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================
  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _expNumberController.dispose();
    _serviceController.dispose();
    _bedController.dispose();

    _diagnosisController.dispose();
    _reasonController.dispose();
    _antecedentsPathController.dispose();
    _antecedentsNonPathController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _vitalsController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _familySocialController.dispose();

    _bloodTypeController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _spo2Controller.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _glucoseController.dispose();
    _abdominalCircController.dispose();

    _subjectiveController.dispose();
    _objectiveController.dispose();
    _generalStateController.dispose();
    _mentalStateController.dispose();
    _consciousnessOtherController.dispose();
    _oxygenationController.dispose();
    _feedingController.dispose();
    _eliminationController.dispose();
    _mobilityController.dispose();
    _hygieneController.dispose();
    _emotionalController.dispose();
    _adultDoseController.dispose();
    _pediatricDoseController.dispose();
    _bmiController.dispose();
    _pamController.dispose();
    _dripController.dispose();
    _insensibleLossesController.dispose();

    _actualProblemController.dispose();
    _potentialProblemController.dispose();

    _nandaSearchCtrl.dispose();
    _nandaCodeCtrl.dispose();
    _nandaLabelCtrl.dispose();
    _nandaDefinitionCtrl.dispose();
    _nandaDomainCtrl.dispose();
    _nandaClassCtrl.dispose();

    _nandaEtiologyController.dispose();
    _nandaSignsController.dispose();

    _nocSearchCtrl.dispose();
    _nicSearchCtrl.dispose();

    _executionController.dispose();
    _evaluationController.dispose();
    _recordsController.dispose();
    _educationController.dispose();
    _contingencyController.dispose();
    _nursingNotesController.dispose();
    _dischargeCriteriaController.dispose();

    _valoracionContentController.dispose();
    _diagnosticoContentController.dispose();
    _planificacionContentController.dispose();
    _ejecucionContentController.dispose();
    _evaluacionContentController.dispose();

    _signatureController.dispose();

    // **Dispose del nuevo controlador**
    _genderOtherController.dispose();

    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    if (_cargandoCatalogos) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorCatalogos != null) {
      return Scaffold(
        appBar: AppBar(
        title: const Text(
          'Generador de PAES',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
          ),
        ),          backgroundColor: const Color.fromARGB(255, 120, 0, 60),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorCatalogos!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _cargarCatalogos,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reintentar"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generador de PAES',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
          ),
        ),        backgroundColor: const Color.fromARGB(255, 120, 0, 60),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < _steps().length - 1) {
            setState(() => _currentStep++);
          } else {
            _savePaes();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: _steps(),
      ),
    );
  }

  // ==========================================================
  // STEPS
  // ==========================================================
  List<Step> _steps() => [
        Step(
          title: const Text('Identificación'),
          content: Column(
            children: [
              TextField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
              // <-- Dropdown con "Otro" incluido
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Masculino', 'Femenino', 'Otro']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v ?? 'Masculino'),
                decoration: const InputDecoration(labelText: 'Sexo'),
              ),
              // <-- Si el usuario selecciona 'Otro', mostramos un TextField para especificar
              if (_gender == 'Otro') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _genderOtherController,
                  decoration: const InputDecoration(labelText: 'Sexo (especifique)'),
                ),
              ],

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDate == null
                          ? 'Fecha de nacimiento'
                          : _birthDate!.toLocal().toString().split(' ')[0],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectBirthDate(context),
                  ),
                ],
              ),
              TextField(
                controller: _expNumberController,
                decoration:
                    const InputDecoration(labelText: 'Número de expediente'),
              ),
              TextField(
                controller: _serviceController,
                decoration: const InputDecoration(labelText: 'Servicio / Área'),
              ),
              TextField(
                controller: _bedController,
                decoration: const InputDecoration(labelText: 'Cama'),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Valoración: ${_valuationDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectValuationDate(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        Step(
          title: const Text('Datos clínicos generales'),
          content: Column(
            children: [
              TextField(
                controller: _diagnosisController,
                decoration:
                    const InputDecoration(labelText: 'Diagnóstico médico'),
              ),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Motivo de ingreso'),
              ),
              TextField(
                controller: _antecedentsPathController,
                decoration: const InputDecoration(
                    labelText: 'Antecedentes personales patológicos'),
              ),
              TextField(
                controller: _antecedentsNonPathController,
                decoration: const InputDecoration(
                    labelText: 'Antecedentes no patológicos'),
              ),
              TextField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Alergias'),
              ),
              TextField(
                controller: _medicationsController,
                decoration:
                    const InputDecoration(labelText: 'Medicamentos prescritos'),
              ),

              // ==========================================================
              // TA EN FORMATO 120 / 80
              // ==========================================================
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _systolicController,
                      decoration: const InputDecoration(labelText: 'TA sistólica'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '/',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _diastolicController,
                      decoration: const InputDecoration(labelText: 'TA diastólica'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              TextField(
                controller: _heartRateController,
                decoration: const InputDecoration(
                    labelText: 'Frecuencia cardiaca (lpm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _respiratoryRateController,
                decoration: const InputDecoration(
                    labelText: 'Frecuencia respiratoria (rpm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _temperatureController,
                decoration: const InputDecoration(labelText: 'Temperatura (°C)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _spo2Controller,
                decoration: const InputDecoration(labelText: 'SpO2 (%)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _glucoseController,
                decoration: const InputDecoration(labelText: 'Glucosa (mg/dL)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _abdominalCircController,
                decoration: const InputDecoration(
                    labelText: 'Circunferencia abdominal (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(labelText: 'Tipo de sangre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Talla (m)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _familySocialController,
                decoration: const InputDecoration(
                    labelText: 'Antecedentes familiares y sociales'),
              ),
            ],
          ),
        ),

        Step(
          title: const Text('Valoración y escalas'),
          content: Column(
            children: [
              TextField(
                controller: _subjectiveController,
                decoration: const InputDecoration(labelText: 'Datos subjetivos'),
              ),
              TextField(
                controller: _objectiveController,
                decoration: const InputDecoration(labelText: 'Datos objetivos'),
              ),
              TextField(
                controller: _valoracionContentController,
                decoration: const InputDecoration(
                    labelText: 'Valoración General'),
              ),
              const SizedBox(height: 10),
              Text('Dolor (EVA): ${_evaPain.toInt()}'),
              Slider(
                value: _evaPain,
                min: 0,
                max: 10,
                divisions: 10,
                label: _evaPain.toInt().toString(),
                onChanged: (v) => setState(() => _evaPain = v),
              ),
              const SizedBox(height: 5),
              Text('Riesgo de caídas (Downton): $_downtonFall'),
              Slider(
                value: _downtonFall.toDouble(),
                min: 0,
                max: 11,
                divisions: 11,
                label: _downtonFall.toString(),
                onChanged: (v) => setState(() => _downtonFall = v.toInt()),
              ),
              const SizedBox(height: 5),
              Text('Riesgo de úlceras (Braden): $_braden'),
              Slider(
                value: _braden.toDouble(),
                min: 0,
                max: 23,
                divisions: 23,
                label: _braden.toString(),
                onChanged: (v) => setState(() => _braden = v.toInt()),
              ),
              const SizedBox(height: 5),
              Text('Estado de conciencia (Glasgow): $_glasgow'),
              Slider(
                value: _glasgow.toDouble(),
                min: 3,
                max: 15,
                divisions: 12,
                label: _glasgow.toString(),
                onChanged: (v) => setState(() => _glasgow = v.toInt()),
              ),
              TextField(
                controller: _generalStateController,
                decoration: const InputDecoration(labelText: 'Estado general'),
              ),
              TextField(
                controller: _mentalStateController,
                decoration: const InputDecoration(labelText: 'Estado mental'),
              ),

              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nivel de conciencia:'),
              ),
              // Opciones solicitadas por el usuario
              RadioListTile<String>(
                title: const Text('Alerta'),
                value: 'Alerta',
                groupValue: _consciousnessSelected,
                onChanged: (v) => setState(() => _consciousnessSelected = v!),
              ),
              RadioListTile<String>(
                title: const Text('Letargo'),
                value: 'Letargo',
                groupValue: _consciousnessSelected,
                onChanged: (v) => setState(() => _consciousnessSelected = v!),
              ),
              RadioListTile<String>(
                title: const Text('Obnubilación'),
                value: 'Obnubilación',
                groupValue: _consciousnessSelected,
                onChanged: (v) => setState(() => _consciousnessSelected = v!),
              ),
              RadioListTile<String>(
                title: const Text('Estupor'),
                value: 'Estupor',
                groupValue: _consciousnessSelected,
                onChanged: (v) => setState(() => _consciousnessSelected = v!),
              ),
              RadioListTile<String>(
                title: const Text('Coma'),
                value: 'Coma',
                groupValue: _consciousnessSelected,
                onChanged: (v) => setState(() => _consciousnessSelected = v!),
              ),
              RadioListTile<String>(
                title: const Text('Otro (Especificar)'),
                value: 'Otro',
                groupValue: _consciousnessSelected,
                onChanged: (v) => setState(() => _consciousnessSelected = v!),
              ),
              if (_consciousnessSelected == 'Otro')
                TextField(
                  controller: _consciousnessOtherController,
                  decoration:
                      const InputDecoration(labelText: 'Especifique el nivel de conciencia'),
                ),

              const SizedBox(height: 20),
              const Divider(),

              // ==========================================================
              // USO DE _addToList (YA NO SALE WARNING)
              // ==========================================================
              const Text(
                "Problemas actuales detectados",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _actualProblemController,
                      decoration:
                          const InputDecoration(labelText: 'Agregar problema actual'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () =>
                        _addToList(_actualProblemController, _actualProblems),
                  ),
                ],
              ),

              for (int i = 0; i < _actualProblems.length; i++)
                ListTile(
                  title: Text(_actualProblems[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeFromList(_actualProblems, i),
                  ),
                ),

              const SizedBox(height: 16),

              const Text(
                "Problemas potenciales detectados",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _potentialProblemController,
                      decoration: const InputDecoration(
                          labelText: 'Agregar problema potencial'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () => _addToList(
                        _potentialProblemController, _potentialProblems),
                  ),
                ],
              ),

              for (int i = 0; i < _potentialProblems.length; i++)
                ListTile(
                  title: Text(_potentialProblems[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeFromList(_potentialProblems, i),
                  ),
                ),
            ],
          ),
        ),

        // ==========================================================
        // NANDA REAL
        // ==========================================================
        Step(
          title: const Text('Diagnóstico NANDA'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buscar diagnóstico NANDA por código o etiqueta"),
              TextField(
                controller: _nandaSearchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar NANDA (ej. 00032 o Dolor agudo)',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _searchNanda(value),
              ),
              const SizedBox(height: 10),
              if (_resultadosNanda.isNotEmpty)
                Column(
                  children: _resultadosNanda.map((n) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text("${n['codigo']} - ${n['etiqueta']}"),
                        subtitle: Text(
                          "${n['definicion'] ?? ''}\nDominio: ${n['dominio'] ?? '-'} • Clase: ${n['clase'] ?? '-'}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectNanda(n),
                        onLongPress: () async {
                          // lee la página desde el JSON: soporta "pagina_pdf" o "pagina"
                          final pagina = int.tryParse((n['pagina_pdf'] ?? n['pagina'] ?? 1).toString()) ?? 1;
                          const assetPath = 'assets/data/nanda.pdf'; // ajusta ruta si hace falta
                          await _openCatalogPdfAtPage(assetPath, pagina, context);
                        },
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _nandaCodeCtrl,
                decoration: const InputDecoration(labelText: 'Código NANDA'),
              ),
              TextField(
                controller: _nandaLabelCtrl,
                decoration: const InputDecoration(labelText: 'Etiqueta NANDA'),
              ),
              TextField(
                controller: _nandaDefinitionCtrl,
                decoration: const InputDecoration(labelText: 'Definición NANDA'),
                maxLines: 3,
              ),
              // Mostrar Dominio y Clase explícitamente
              TextField(
                controller: _nandaDomainCtrl,
                decoration: const InputDecoration(labelText: 'Dominio'),
              ),
              TextField(
                controller: _nandaClassCtrl,
                decoration: const InputDecoration(labelText: 'Clase'),
              ),
              TextField(
                controller: _nandaEtiologyController,
                decoration: const InputDecoration(labelText: 'Etiología'),
              ),
              TextField(
                controller: _nandaSignsController,
                decoration: const InputDecoration(labelText: 'Signos y síntomas'),
              ),
              DropdownButtonFormField(
                initialValue: _priority,
                items: ['Alta', 'Media', 'Baja']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v.toString()),
                decoration: const InputDecoration(labelText: 'Prioridad'),
              ),
              TextField(
                controller: _diagnosticoContentController,
                decoration: const InputDecoration(
                    labelText: 'Diagnóstico General'),
              ),
            ],
          ),
        ),

        // ==========================================================
        // PLANIFICACIÓN REAL NOC/NIC
        // ==========================================================
        Step(
          title: const Text('Planificación NOC/NIC'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buscar Objetivos NOC',
              ),
              TextField(
                controller: _nocSearchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar NOC por código o etiqueta',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _searchNoc(value),
              ),
              const SizedBox(height: 10),
              if (_resultadosNoc.isNotEmpty)
                Column(
                  children: _resultadosNoc.take(10).map((n) {
                    final value = "${n['codigo']} - ${n['etiqueta']} (${n['dominio'] ?? ''} / ${n['clase'] ?? ''})";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(value),
                        subtitle: Text("Dominio: ${n['dominio'] ?? '-'} • Clase: ${n['clase'] ?? '-'}"),
                        onTap: () {
                          setState(() {
                            if (!_nocObjectives.contains(value)) {
                              _nocObjectives.add(value);
                            }
                            _resultadosNoc = [];
                            _nocSearchCtrl.clear();
                          });
                        },
                        onLongPress: () async {
                          // permitir abrir el PDF de NOC en la página referenciada (si existe)
                          final pagina = int.tryParse((n['pagina_pdf'] ?? n['pagina'] ?? 1).toString()) ?? 1;
                          const assetPath = 'assets/data/noc.pdf';
                          await _openCatalogPdfAtPage(assetPath, pagina, context);
                        },
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              const Text('Objetivos NOC seleccionados:'),
              for (var obj in _nocObjectives)
                ListTile(
                  title: Text(obj),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeFromList(
                        _nocObjectives, _nocObjectives.indexOf(obj)),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Buscar Intervenciones NIC',
              ),
              TextField(
                controller: _nicSearchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar NIC por código o etiqueta',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _searchNic(value),
              ),
              const SizedBox(height: 10),
              if (_resultadosNic.isNotEmpty)
                Column(
                  children: _resultadosNic.take(10).map((n) {
                    final value = "${n['codigo']} - ${n['etiqueta']} (${n['dominio'] ?? ''} / ${n['clase'] ?? ''})";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(value),
                        subtitle: Text("Dominio: ${n['dominio'] ?? '-'} • Clase: ${n['clase'] ?? '-'}"),
                        onTap: () {
                          setState(() {
                            if (!_nicInterventions.contains(value)) {
                              _nicInterventions.add(value);
                            }
                            _resultadosNic = [];
                            _nicSearchCtrl.clear();
                          });
                        },
                        onLongPress: () async {
                          // abrir PDF NIC en la página indicada si está presente
                          final pagina = int.tryParse((n['pagina_pdf'] ?? n['pagina'] ?? 1).toString()) ?? 1;
                          const assetPath = 'assets/data/nic.pdf';
                          await _openCatalogPdfAtPage(assetPath, pagina, context);
                        },
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              const Text('Intervenciones NIC seleccionadas:'),
              for (var nic in _nicInterventions)
                ListTile(
                  title: Text(nic),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeFromList(
                        _nicInterventions, _nicInterventions.indexOf(nic)),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _planificacionContentController,
                decoration: const InputDecoration(
                    labelText: 'Planificación General'),
              ),
            ],
          ),
        ),

        Step(
          title: const Text('Ejecución'),
          content: Column(
            children: [
              TextField(
                controller: _executionController,
                decoration: const InputDecoration(labelText: 'Notas de ejecución'),
              ),
              TextField(
                controller: _ejecucionContentController,
                decoration: const InputDecoration(
                    labelText: ' Ejecución General'),
              ),
              TextField(
                controller: _recordsController,
                decoration:
                    const InputDecoration(labelText: 'Registros de enfermería'),
              ),
            ],
          ),
        ),

        Step(
          title: const Text('Evaluación y alta'),
          content: Column(
            children: [
              TextField(
                controller: _evaluationController,
                decoration: const InputDecoration(labelText: 'Evaluación final'),
              ),
              TextField(
                controller: _evaluacionContentController,
                decoration: const InputDecoration(
                    labelText: ' Evaluación General'),
              ),
              TextField(
                controller: _educationController,
                decoration:
                    const InputDecoration(labelText: 'Educación al paciente'),
              ),
              TextField(
                controller: _contingencyController,
                decoration:
                    const InputDecoration(labelText: 'Plan de contingencia'),
              ),
              TextField(
                controller: _dischargeCriteriaController,
                decoration: const InputDecoration(labelText: 'Criterios de egreso'),
              ),
              TextField(
                controller: _nursingNotesController,
                decoration: const InputDecoration(
                    labelText: 'Notas de enfermería adicionales'),
              ),
              TextField(
                controller: _signatureController,
                decoration: const InputDecoration(labelText: 'Nombre y firma'),
              ),
              DropdownButtonFormField(
                initialValue: _category,
                items: ['Enfermero/a', 'Licenciado/a', 'Auxiliar']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v.toString()),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              DropdownButtonFormField(
                initialValue: _shift,
                items: ['Matutino', 'Vespertino', 'Nocturno']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _shift = v.toString()),
                decoration: const InputDecoration(labelText: 'Turno'),
              ),
            ],
          ),
        ),
      ];
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ═══════════════════════════════════════*/
