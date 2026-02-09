/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/*══════════════════════════════════════════════*/

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

/*══════════════════════════════════════════════*/

class _CalculadoraScreenState extends State<CalculadoraScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ────────── Controllers ──────────
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _patientWeightController = TextEditingController();
  final TextEditingController _fluidController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _flowController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // ────────── Laboratorio ──────────
  final TextEditingController _naController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _clController = TextEditingController();
  final TextEditingController _creatininaController = TextEditingController();
  final TextEditingController _paO2Controller = TextEditingController();

  // ────────── Resultados ──────────
  double? imcResult;
  double? pamResult;
  double? adultDoseResult;
  double? pediatricDoseResult;
  double? neonatalDoseResult;

  double? dripResult;
  double? insensibleResult;
  double? balanceResult;

  // Frecuencia cardiaca por edad (mínima / esperada / máxima)
  double? hrMinResult;
  double? hrExpectedResult;
  double? hrMaxResult;

  // Respiratorio
  double? fiO2Result;
  double? pfRatioResult;

  // Renal
  double? gfrResult;

  // Electrolitos (diferencia vs referencia)
  double? naDiffResult;
  double? kDiffResult;
  double? clDiffResult;

  // ────────── Sistema profesional de pacientes ──────────
  static const String _storageKey = "polisafe_calculadora_data";
  static const String _storageCurrentPatientKey =
      "polisafe_calculadora_current_patient";

  final Map<String, List<String>> _historyByPatient = {};
  // Nuevo: historial "guardado" en apartado separado
  final Map<String, List<String>> _savedHistoryByPatient = {};

  String _currentPatient = "Paciente 1";

  bool _cargando = true;

  // ────────── Calculadora inteligente ──────────
  final List<String> suggestedCalculations = [];

  // ────────── Configuración de seguridad ──────────
  static const int _maxHistoryPerPatient = 120;
  static const int _maxPatients = 50;

  // ────────── Rendimiento (Debounce / Throttle) ──────────
  Timer? _suggestDebounce;
  Timer? _saveDebounce;

  // ────────── Configuración de cálculo clínico ──────────
  int _dropFactor = 20; // gotas/mL (macro estándar)
  String _sexo = "Hombre"; // Para Cockcroft-Gault

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 7, vsync: this);

    _weightController.addListener(_updateSuggestedCalculations);
    _heightController.addListener(_updateSuggestedCalculations);
    _ageController.addListener(_updateSuggestedCalculations);
    _systolicController.addListener(_updateSuggestedCalculations);
    _diastolicController.addListener(_updateSuggestedCalculations);

    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _suggestDebounce?.cancel();
    _saveDebounce?.cancel();

    for (var c in [
      _weightController,
      _heightController,
      _systolicController,
      _diastolicController,
      _doseController,
      _patientWeightController,
      _fluidController,
      _hoursController,
      _inputController,
      _outputController,
      _flowController,
      _ageController,
      _naController,
      _kController,
      _clController,
      _creatininaController,
      _paO2Controller,
    ]) {
      c.dispose();
    }

    super.dispose();
  }

  // ────────── Persistencia (Guardar / Cargar) ──────────

  Future<void> _guardarDatos() async {
    _saveDebounce?.cancel();

    _saveDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final prefs = await SharedPreferences.getInstance();

        final Map<String, dynamic> data = {
          // Guardar ambos historiales para compatibilidad y apartado separado
          "patients": _historyByPatient,
          "savedHistory": _savedHistoryByPatient,
          "sexo": _sexo,
          "dropFactor": _dropFactor,
        };

        await prefs.setString(_storageKey, jsonEncode(data));
        await prefs.setString(_storageCurrentPatientKey, _currentPatient);
      } catch (_) {
        // Evitar crasheos
      }
    });
  }

  Future<void> _cargarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? data = prefs.getString(_storageKey);
      final String? savedPatient = prefs.getString(_storageCurrentPatientKey);

      if (data != null && data.isNotEmpty) {
        final decoded = jsonDecode(data);

        if (decoded is Map) {
          if (decoded["patients"] != null) {
            final Map<String, dynamic> patients =
                Map<String, dynamic>.from(decoded["patients"]);

            _historyByPatient.clear();

            patients.forEach((key, value) {
              if (value is List) {
                _historyByPatient[key] = List<String>.from(value);
              }
            });
          }

          // Cargar savedHistory si existe (nuevo apartado)
          if (decoded["savedHistory"] != null) {
            final Map<String, dynamic> saved =
                Map<String, dynamic>.from(decoded["savedHistory"]);

            _savedHistoryByPatient.clear();

            saved.forEach((key, value) {
              if (value is List) {
                _savedHistoryByPatient[key] = List<String>.from(value);
              }
            });
          }

          if (decoded["sexo"] is String) {
            _sexo = decoded["sexo"];
          }

          if (decoded["dropFactor"] is int) {
            _dropFactor = decoded["dropFactor"];
          }
        }
      }

      if (_historyByPatient.isEmpty) {
        _historyByPatient["Paciente 1"] = [];
      }

      if (_savedHistoryByPatient.isEmpty) {
        // Asegurar que exista la entrada correspondiente aunque esté vacía
        _savedHistoryByPatient["Paciente 1"] = [];
      }

      if (savedPatient != null &&
          savedPatient.isNotEmpty &&
          _historyByPatient.containsKey(savedPatient)) {
        _currentPatient = savedPatient;
      } else {
        _currentPatient = _historyByPatient.keys.first;
      }
    } catch (_) {
      _historyByPatient.clear();
      _historyByPatient["Paciente 1"] = [];
      _savedHistoryByPatient.clear();
      _savedHistoryByPatient["Paciente 1"] = [];
      _currentPatient = "Paciente 1";
      _sexo = "Hombre";
      _dropFactor = 20;
    }

    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }

  // ────────── Helpers ──────────

  String _formatDouble(double? value) =>
      value == null ? '--' : value.toStringAsFixed(2);

  void _notify(String message, {Color color = Colors.red}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resultado copiado al portapapeles')),
    );
  }

  // Formateador decimal seguro (evita 12..3, ... , etc)
  List<TextInputFormatter> _decimalInputFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;

        if (text.isEmpty) return newValue;

        // Solo un punto decimal permitido
        if ('.'.allMatches(text).length > 1) return oldValue;

        return newValue;
      }),
    ];
  }

  void _updateSuggestedCalculations() {
    _suggestDebounce?.cancel();

    _suggestDebounce = Timer(const Duration(milliseconds: 250), () {
      suggestedCalculations.clear();

      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);
      final age = double.tryParse(_ageController.text);

      if (weight != null && height != null && height > 0 && weight > 0) {
        suggestedCalculations.add('IMC');
      }

      if (age != null && age > 0) {
        suggestedCalculations.add('Frecuencia cardiaca por edad');
      }

      final sys = double.tryParse(_systolicController.text);
      final dia = double.tryParse(_diastolicController.text);

      if (sys != null && dia != null) {
        suggestedCalculations.add('PAM');
      }

      if (mounted) setState(() {});
    });
  }

  // ────────── Gestión Profesional de Pacientes ──────────

  Future<void> _crearPaciente() async {
    if (_historyByPatient.length >= _maxPatients) {
      _notify("Límite de pacientes alcanzado ($_maxPatients)",
          color: Colors.orange);
      return;
    }

    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo Paciente"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Ej: Juan Pérez",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();

              if (name.isEmpty) return;

              if (_historyByPatient.containsKey(name)) {
                _notify("Ya existe un paciente con ese nombre",
                    color: Colors.orange);
                return;
              }

              setState(() {
                _historyByPatient[name] = [];
                _savedHistoryByPatient[name] = [];
                _currentPatient = name;
              });

              _guardarDatos();
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  Future<void> _renombrarPaciente(String oldName) async {
    final controller = TextEditingController(text: oldName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Renombrar Paciente"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Nuevo nombre",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();

              if (newName.isEmpty) return;

              if (_historyByPatient.containsKey(newName)) {
                _notify("Ese nombre ya existe", color: Colors.orange);
                return;
              }

              setState(() {
                final history = _historyByPatient.remove(oldName);
                _historyByPatient[newName] = history ?? [];

                final saved = _savedHistoryByPatient.remove(oldName);
                _savedHistoryByPatient[newName] = saved ?? [];

                if (_currentPatient == oldName) {
                  _currentPatient = newName;
                }
              });

              _guardarDatos();
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPaciente(String name) async {
    if (_historyByPatient.length == 1) {
      _notify("Debe existir al menos un paciente", color: Colors.orange);
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar Paciente"),
        content: Text(
          "¿Seguro que deseas eliminar a \"$name\"?\n\nEsto borrará todo su historial.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _historyByPatient.remove(name);
                _savedHistoryByPatient.remove(name);

                if (_currentPatient == name) {
                  _currentPatient = _historyByPatient.keys.first;
                }
              });

              _guardarDatos();
              Navigator.pop(context);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  void _addToHistory(String calculation) {
    setState(() {
      _historyByPatient.putIfAbsent(_currentPatient, () => []);
      _historyByPatient[_currentPatient]!.insert(0, calculation);

      if (_historyByPatient[_currentPatient]!.length > _maxHistoryPerPatient) {
        _historyByPatient[_currentPatient]!.removeRange(
          _maxHistoryPerPatient,
          _historyByPatient[_currentPatient]!.length,
        );
      }
    });

    // Además lo guardamos en el apartado separado
    _addToSavedHistory(calculation);

    _guardarDatos();
  }

  void _addToSavedHistory(String calculation) {
    setState(() {
      _savedHistoryByPatient.putIfAbsent(_currentPatient, () => []);
      _savedHistoryByPatient[_currentPatient]!.insert(0, calculation);

      if (_savedHistoryByPatient[_currentPatient]!.length >
          _maxHistoryPerPatient) {
        _savedHistoryByPatient[_currentPatient]!.removeRange(
          _maxHistoryPerPatient,
          _savedHistoryByPatient[_currentPatient]!.length,
        );
      }
    });

    _guardarDatos();
  }

  Future<void> _limpiarHistorialPaciente() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Limpiar Historial"),
        content: Text("¿Deseas borrar todo el historial de $_currentPatient?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _historyByPatient[_currentPatient]?.clear();
              });

              _guardarDatos();
              Navigator.pop(context);
            },
            child: const Text("Borrar"),
          ),
        ],
      ),
    );
  }

  // Nuevo: limpiar historial guardado del paciente
  Future<void> _limpiarHistorialGuardadoPaciente() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Limpiar Historial guardado"),
        content:
            Text("¿Deseas borrar todo el historial guardado de $_currentPatient?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _savedHistoryByPatient[_currentPatient]?.clear();
              });

              _guardarDatos();
              Navigator.pop(context);
            },
            child: const Text("Borrar"),
          ),
        ],
      ),
    );
  }

  // ────────── Generar PDF ──────────

  Future<void> _generarPdfPacienteActual() async {
    try {
      // Limitar historial para evitar PDF gigante y lag
      final history =
          (_historyByPatient[_currentPatient] ?? []).take(80).toList();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Text(
                "POLISAFE - REPORTE DE CÁLCULOS",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Paciente: $_currentPatient",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Fecha: ${DateTime.now().toString().substring(0, 19)}",
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                "Historial de cálculos (últimos ${history.length})",
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (history.isEmpty)
                pw.Text("No hay historial registrado.")
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: history.map((e) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 6),
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(e, style: const pw.TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                ),
              pw.SizedBox(height: 15),
              pw.Divider(),
              pw.Text(
                "Generado automáticamente por POLISAFE",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      _notify("PDF generado correctamente", color: Colors.green);
    } catch (_) {
      _notify("Error al generar PDF", color: Colors.red);
    }
  }

  // ────────── Cálculos ──────────

  void calculateIMC() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null ||
        height == null ||
        height <= 0 ||
        weight <= 0 ||
        height > 300 ||
        weight > 400) {
      _notify("Ingresa peso y altura válidos", color: Colors.orange);
      return;
    }

    setState(() {
      imcResult = weight / pow(height / 100, 2);
    });

    if (imcResult! < 18.5) _notify('IMC bajo', color: Colors.orange);
    if (imcResult! >= 30) _notify('IMC alto', color: Colors.red);

    _addToHistory('IMC: ${_formatDouble(imcResult)}');
  }

  void calculatePAM() {
    final systolic = double.tryParse(_systolicController.text);
    final diastolic = double.tryParse(_diastolicController.text);

    if (systolic == null ||
        diastolic == null ||
        systolic <= 0 ||
        diastolic <= 0 ||
        systolic > 300 ||
        diastolic > 200) {
      _notify("Ingresa valores válidos", color: Colors.orange);
      return;
    }

    setState(() {
      pamResult = (systolic + 2 * diastolic) / 3;
    });

    if (pamResult! < 70) _notify('PAM baja', color: Colors.orange);
    if (pamResult! > 100) _notify('PAM alta', color: Colors.red);

    _addToHistory('PAM: ${_formatDouble(pamResult)} mmHg');
  }

  // Reemplazada: Frecuencia cardiaca con separación clara entre Máx / Esperada (reposo) / Mín
  void calculateHeartRateByAge() {
    final age = double.tryParse(_ageController.text);

    if (age == null || age <= 0 || age > 120) {
      _notify("Ingresa una edad válida", color: Colors.orange);
      return;
    }

    // FC máxima (Tanaka)
    final fcMax = 208 - (0.7 * age);

    // FC esperada en reposo (ajustada levemente por edad, pero con límite inferior 60)
    final fcExpected = max(60.0, 75.0 - (age * 0.05));

    // FC mínima fisiológica que consideramos (clínica general)
    final fcMin = 60.0;

    setState(() {
      hrMinResult = fcMin;
      hrExpectedResult = fcExpected;
      hrMaxResult = fcMax;
    });

    _addToHistory(
      'FC por edad → Mín: ${_formatDouble(hrMinResult)} bpm | '
      'Esperada: ${_formatDouble(hrExpectedResult)} bpm | '
      'Máx: ${_formatDouble(hrMaxResult)} bpm',
    );

    _notify(
      "FC Máx: ${_formatDouble(hrMaxResult)} bpm | FC Esperada: ${_formatDouble(hrExpectedResult)} bpm",
      color: Colors.green,
    );
  }

  void calculateDoses() {
    final doseMg = double.tryParse(_doseController.text);
    final weight = double.tryParse(_patientWeightController.text);

    if (doseMg == null || weight == null || weight <= 0 || doseMg <= 0) {
      _notify("Ingresa dosis y peso válidos", color: Colors.orange);
      return;
    }

    setState(() {
      adultDoseResult = doseMg;
      pediatricDoseResult = doseMg * weight / 70;

      // Neonato: alometría (mejor controlando mínimo)
      neonatalDoseResult = doseMg * pow(weight / 3, 0.75);
    });

    _addToHistory(
      'Dosis → Adulto: ${_formatDouble(adultDoseResult)} mg | Pediátrico: ${_formatDouble(pediatricDoseResult)} mg | Neonato: ${_formatDouble(neonatalDoseResult)} mg',
    );
  }

  void calculateDrip() {
    final fluid = double.tryParse(_fluidController.text);
    final hours = double.tryParse(_hoursController.text);

    if (fluid == null || hours == null || hours <= 0 || fluid <= 0) {
      _notify("Ingresa volumen y horas válidas", color: Colors.orange);
      return;
    }

    setState(() {
      dripResult = (fluid * _dropFactor) / (hours * 60);
    });

    _addToHistory(
        'Goteo: ${_formatDouble(dripResult)} gotas/min | Factor: $_dropFactor gtt/mL');
  }

  void calculateInsensible() {
    final weight = double.tryParse(_patientWeightController.text);

    if (weight == null || weight <= 0 || weight > 400) {
      _notify("Ingresa un peso válido", color: Colors.orange);
      return;
    }

    setState(() {
      // Estimación rápida:
      // <10 kg: 150 mL/kg/día
      // >=10 kg: 100 mL/kg/día
      insensibleResult = weight < 10 ? weight * 150 : weight * 100;
    });

    _addToHistory(
      'Pérdidas insensibles (estimación): ${_formatDouble(insensibleResult)} mL/día',
    );
  }

  void calculateBalance() {
    final input = double.tryParse(_inputController.text);
    final output = double.tryParse(_outputController.text);

    if (input == null || output == null) {
      _notify("Ingresa valores válidos", color: Colors.orange);
      return;
    }

    setState(() {
      balanceResult = input - output;
    });

    _addToHistory('Balance hídrico: ${_formatDouble(balanceResult)} mL');
  }

  void calculateElectrolytes() {
    final na = double.tryParse(_naController.text);
    final k = double.tryParse(_kController.text);
    final cl = double.tryParse(_clController.text);

    setState(() {
      naDiffResult = na != null ? (140 - na) : null;
      kDiffResult = k != null ? (4 - k) : null;
      clDiffResult = cl != null ? (100 - cl) : null;
    });

    _addToHistory(
      'Diferencia vs referencia → Na: ${_formatDouble(naDiffResult)} | K: ${_formatDouble(kDiffResult)} | Cl: ${_formatDouble(clDiffResult)}',
    );

    _notify("Cálculo realizado (solo diferencia, no dosis)",
        color: Colors.green);
  }

  void calculateGFR() {
    final creat = double.tryParse(_creatininaController.text);
    final age = double.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);

    if (creat == null ||
        age == null ||
        weight == null ||
        creat <= 0 ||
        age <= 0 ||
        weight <= 0) {
      _notify("Ingresa creatinina, edad y peso válidos", color: Colors.orange);
      return;
    }

    double gfr = ((140 - age) * weight) / (72 * creat);

    // Factor mujer
    if (_sexo == "Mujer") {
      gfr *= 0.85;
    }

    setState(() {
      gfrResult = gfr;
    });

    _addToHistory(
        'GFR estimado (Cockcroft-Gault $_sexo): ${_formatDouble(gfrResult)} mL/min');
  }

  void calculateRespiratory() {
    final paO2 = double.tryParse(_paO2Controller.text);
    final flow = double.tryParse(_flowController.text);

    if (paO2 == null || paO2 <= 0 || paO2 > 700) {
      _notify("Ingresa PaO₂ válida", color: Colors.orange);
      return;
    }

    if (flow == null || flow < 0 || flow > 30) {
      _notify("Ingresa flujo válido", color: Colors.orange);
      return;
    }

    setState(() {
      // Estimación FiO2 con cánula nasal aproximada (simple)
      fiO2Result = min(1, 0.21 + 0.03 * flow) * 100;

      // Esto NO es OxIndex real, es PaO2/FiO2
      pfRatioResult = paO2 / (fiO2Result! / 100);
    });

    String interpretation;
    if (pfRatioResult! >= 300) {
      interpretation = 'Normal';
    } else if (pfRatioResult! >= 200) {
      interpretation = 'Leve';
    } else if (pfRatioResult! >= 100) {
      interpretation = 'Moderada';
    } else {
      interpretation = 'Severa';
    }

    _addToHistory(
      'P/F Ratio: ${_formatDouble(pfRatioResult)} | FiO₂: ${_formatDouble(fiO2Result)}% | $interpretation',
    );

    _notify(
      "P/F Ratio: ${_formatDouble(pfRatioResult)} → $interpretation",
      color: Colors.green,
    );
  }

  // ────────── Widgets Reutilizables ──────────

  Widget inputField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: _decimalInputFormatters(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _resultCard(String title, String value) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$title: $value",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              tooltip: "Copiar",
              icon: const Icon(Icons.copy),
              onPressed: value == '--' ? null : () => _copyToClipboard(value),
            )
          ],
        ),
      ),
    );
  }

  Widget patientSelector() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _currentPatient,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _historyByPatient.keys
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _currentPatient = v);
                      _guardarDatos();
                    },
                  ),
                ),
                IconButton(
                  tooltip: "Nuevo paciente",
                  icon: const Icon(Icons.person_add),
                  onPressed: _crearPaciente,
                ),
                IconButton(
                  tooltip: "Renombrar",
                  icon: const Icon(Icons.edit),
                  onPressed: () => _renombrarPaciente(_currentPatient),
                ),
                IconButton(
                  tooltip: "Eliminar paciente",
                  icon: const Icon(Icons.delete),
                  onPressed: () => _eliminarPaciente(_currentPatient),
                ),
                // Nuevo botón: ver historial guardado (apartado)
                IconButton(
                  tooltip: "Ver historial guardado",
                  icon: const Icon(Icons.archive),
                  onPressed: _showSavedHistoryDialog,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Sexo + Factor de goteo (configuración clínica rápida)
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Configuración rápida:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sexo,
                  items: const [
                    DropdownMenuItem(value: "Hombre", child: Text("Hombre")),
                    DropdownMenuItem(value: "Mujer", child: Text("Mujer")),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _sexo = v);
                    _guardarDatos();
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _dropFactor,
                  items: const [
                    DropdownMenuItem(value: 10, child: Text("10 gtt")),
                    DropdownMenuItem(value: 15, child: Text("15 gtt")),
                    DropdownMenuItem(value: 20, child: Text("20 gtt")),
                    DropdownMenuItem(value: 60, child: Text("60 gtt")),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _dropFactor = v);
                    _guardarDatos();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget historyList() {
    final history = _historyByPatient[_currentPatient];

    return SizedBox(
      height: 240,
      child: history == null || history.isEmpty
          ? const Center(child: Text('No hay historial'))
          : ListView.builder(
              itemCount: history.length,
              itemExtent: 72,
              cacheExtent: 400,
              itemBuilder: (_, index) {
                final item = history[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      item,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(item),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ────────── Mostrar historial guardado (apartado separado) ──────────
  Future<void> _showSavedHistoryDialog() async {
    final list = _savedHistoryByPatient.putIfAbsent(_currentPatient, () => []);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Historial guardado - $_currentPatient'),
            content: SizedBox(
              width: double.maxFinite,
              child: list.isEmpty
                  ? const Center(child: Text('No hay historial guardado'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final item = list[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.archive),
                            title: Text(
                              item,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Copiar',
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    _copyToClipboard(item);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setStateDialog(() {
                                      _savedHistoryByPatient[_currentPatient]!
                                          .removeAt(index);
                                    });
                                    _guardarDatos();
                                  },
                                ),
                              ],
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _limpiarHistorialGuardadoPaciente();
                },
                child: const Text(
                  'Limpiar todo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  // ────────── Build ──────────

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora para Enfermería'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Generar PDF",
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generarPdfPacienteActual,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Vitales'),
            Tab(text: 'Dosis'),
            Tab(text: 'Líquidos'),
            Tab(text: 'IMC'),
            Tab(text: 'Laboratorio'),
            Tab(text: 'Respiratorio'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // VITALES
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                inputField('Sistólica (mmHg)', _systolicController),
                inputField('Diastólica (mmHg)', _diastolicController),
                ElevatedButton(
                  onPressed: calculatePAM,
                  child: const Text('Calcular PAM'),
                ),
                _resultCard('PAM', '${_formatDouble(pamResult)} mmHg'),
                inputField('Edad (años)', _ageController),
                ElevatedButton(
                  onPressed: calculateHeartRateByAge,
                  child: const Text('Frecuencia cardiaca por edad'),
                ),
                _resultCard('FC Mín', '${_formatDouble(hrMinResult)} bpm'),
                _resultCard(
                    'FC Esperada', '${_formatDouble(hrExpectedResult)} bpm'),
                _resultCard('FC Máx', '${_formatDouble(hrMaxResult)} bpm'),
                historyList(),
              ],
            ),
          ),

          // DOSIS
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                inputField('Dosis estándar (mg)', _doseController),
                inputField('Peso paciente (kg)', _patientWeightController),
                ElevatedButton(
                  onPressed: calculateDoses,
                  child: const Text('Calcular Dosis'),
                ),
                _resultCard('Adulto', '${_formatDouble(adultDoseResult)} mg'),
                _resultCard(
                    'Pediátrico', '${_formatDouble(pediatricDoseResult)} mg'),
                _resultCard(
                    'Neonato', '${_formatDouble(neonatalDoseResult)} mg'),
                historyList(),
              ],
            ),
          ),

          // LÍQUIDOS
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                inputField('Volumen (mL)', _fluidController),
                inputField('Horas', _hoursController),
                ElevatedButton(
                  onPressed: calculateDrip,
                  child: const Text('Calcular Goteo'),
                ),
                _resultCard(
                  'Goteo',
                  '${_formatDouble(dripResult)} gotas/min',
                ),
                inputField('Entrada (mL)', _inputController),
                inputField('Salida (mL)', _outputController),
                ElevatedButton(
                  onPressed: calculateBalance,
                  child: const Text('Calcular Balance'),
                ),
                _resultCard('Balance hídrico',
                    '${_formatDouble(balanceResult)} mL'),
                ElevatedButton(
                  onPressed: calculateInsensible,
                  child: const Text('Pérdidas insensibles'),
                ),
                _resultCard(
                    'Pérdidas', '${_formatDouble(insensibleResult)} mL/día'),
                historyList(),
              ],
            ),
          ),

          // IMC
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                inputField('Peso (kg)', _weightController),
                inputField('Altura (cm)', _heightController),
                ElevatedButton(
                  onPressed: calculateIMC,
                  child: const Text('Calcular IMC'),
                ),
                _resultCard('IMC', _formatDouble(imcResult)),
                historyList(),
              ],
            ),
          ),

          // LABORATORIO
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                inputField('Na (mEq/L)', _naController),
                inputField('K (mEq/L)', _kController),
                inputField('Cl (mEq/L)', _clController),
                inputField('Creatinina (mg/dL)', _creatininaController),
                ElevatedButton(
                  onPressed: calculateElectrolytes,
                  child: const Text('Calcular Diferencias'),
                ),
                _resultCard('Δ Na', _formatDouble(naDiffResult)),
                _resultCard('Δ K', _formatDouble(kDiffResult)),
                _resultCard('Δ Cl', _formatDouble(clDiffResult)),
                ElevatedButton(
                  onPressed: calculateGFR,
                  child: const Text('Calcular GFR'),
                ),
                _resultCard('GFR', '${_formatDouble(gfrResult)} mL/min'),
                historyList(),
              ],
            ),
          ),

          // RESPIRATORIO
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                inputField('PaO₂ (mmHg)', _paO2Controller),
                inputField('Flujo O₂ (L/min)', _flowController),
                ElevatedButton(
                  onPressed: calculateRespiratory,
                  child: const Text('Calcular P/F Ratio'),
                ),
                _resultCard('FiO₂ estimada', '${_formatDouble(fiO2Result)}%'),
                _resultCard('P/F Ratio', _formatDouble(pfRatioResult)),
                historyList(),
              ],
            ),
          ),

          // HISTORIAL GENERAL
          _tabWrapper(
            child: Column(
              children: [
                patientSelector(),
                ElevatedButton.icon(
                  onPressed: _generarPdfPacienteActual,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Generar PDF del paciente"),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _limpiarHistorialPaciente,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Borrar historial del paciente"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                const SizedBox(height: 12),
                historyList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────── Wrapper para evitar crasheos por overflow ──────────

  Widget _tabWrapper({required Widget child}) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
