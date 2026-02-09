/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/*══════════════════════════════════════════════*/

class Paciente {

  final String id;
  String nombre;
  int edad;
  String sexo;
  double peso;
  double estatura;
  String diagnostico;

  Paciente({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.peso,
    required this.estatura,
    required this.diagnostico,
  });

  /*══════════════════════════════════════════════*/
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nombre": nombre,
      "edad": edad,
      "sexo": sexo,
      "peso": peso,
      "estatura": estatura,
      "diagnostico": diagnostico,
    };
  }

  /*══════════════════════════════════════════════*/
  factory Paciente.fromMap(Map<String, dynamic> map) {

    return Paciente(
      id: map["id"] ?? "",
      nombre: map["nombre"] ?? "Paciente",
      edad: map["edad"] ?? 0,
      sexo: map["sexo"] ?? "No especificado",
      peso: (map["peso"] ?? 0).toDouble(),
      estatura: (map["estatura"] ?? 0).toDouble(),
      diagnostico: map["diagnostico"] ?? "",
    );
  }
}

/*══════════════════════════════════════════════*/

class PacienteService {

  static const String _keyPacientes = "pacientes_lista";
  static const String _keyActivo = "paciente_activo";

  static final List<Paciente> _pacientes = [];
  static Paciente? _activo;

  /*══════════════════════════════════════════════*/
  /// Cargar pacientes desde SharedPreferences
  static Future<void> cargar() async {

    final prefs = await SharedPreferences.getInstance();

    final String? dataPacientes = prefs.getString(_keyPacientes);
    final String? dataActivo = prefs.getString(_keyActivo);

    _pacientes.clear();
    _activo = null;

    // ───────────────────────────────
    // Cargar lista de pacientes
    if (dataPacientes != null && dataPacientes.isNotEmpty) {

      try {

        final decoded = jsonDecode(dataPacientes);

        if (decoded is List) {

          _pacientes.addAll(
            decoded.map((e) => Paciente.fromMap(Map<String, dynamic>.from(e))).toList(),
          );
        }

      } catch (e) {
        _pacientes.clear();
      }
    }

    // ───────────────────────────────
    // Cargar paciente activo
    if (dataActivo != null && dataActivo.isNotEmpty) {

      try {

        final decoded = jsonDecode(dataActivo);

        if (decoded is Map) {
          _activo = Paciente.fromMap(Map<String, dynamic>.from(decoded));
        }

      } catch (e) {
        _activo = null;
      }
    }

    // ───────────────────────────────
    // Validación: si el activo no existe en lista
    if (_activo != null) {

      final existe = _pacientes.any((p) => p.id == _activo!.id);

      if (!existe) {
        _activo = null;
      }
    }

    // ───────────────────────────────
    // Si no hay activo pero sí pacientes, asignar el primero
    if (_activo == null && _pacientes.isNotEmpty) {
      _activo = _pacientes.first;
      await guardarActivo(_activo!);
    }
  }

  /*══════════════════════════════════════════════*/
  /// Guardar lista completa de pacientes
  static Future<void> _guardarLista() async {

    final prefs = await SharedPreferences.getInstance();

    final data = _pacientes.map((p) => p.toMap()).toList();

    await prefs.setString(_keyPacientes, jsonEncode(data));
  }

  /*══════════════════════════════════════════════*/
  /// Guardar paciente activo
  static Future<void> guardarActivo(Paciente paciente) async {

    final prefs = await SharedPreferences.getInstance();

    _activo = paciente;

    await prefs.setString(_keyActivo, jsonEncode(paciente.toMap()));
  }

  /*══════════════════════════════════════════════*/
  /// Obtener paciente activo
  static Paciente? obtenerActivo() {
    return _activo;
  }

  /*══════════════════════════════════════════════*/
  /// Obtener lista de pacientes
  static List<Paciente> obtenerPacientes() {
    return List.unmodifiable(_pacientes);
  }

  /*══════════════════════════════════════════════*/
  /// Buscar paciente por ID
  static Paciente? obtenerPorId(String id) {

    try {
      return _pacientes.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /*══════════════════════════════════════════════*/
  /// Agregar paciente nuevo
  static Future<void> agregarPaciente(Paciente paciente) async {

    if (paciente.id.trim().isEmpty) return;

    final existe = _pacientes.any((p) => p.id == paciente.id);

    if (existe) return;

    _pacientes.add(paciente);

    await _guardarLista();

    // si no hay activo, este será el activo
    if (_activo == null) {
      await guardarActivo(paciente);
    }
  }

  /*══════════════════════════════════════════════*/
  /// Actualizar paciente existente
  static Future<void> actualizarPaciente(Paciente paciente) async {

    final index = _pacientes.indexWhere((p) => p.id == paciente.id);

    if (index == -1) return;

    _pacientes[index] = paciente;

    await _guardarLista();

    // si es el activo, también actualizar activo
    if (_activo?.id == paciente.id) {
      await guardarActivo(paciente);
    }
  }

  /*══════════════════════════════════════════════*/
  /// Eliminar paciente por ID
  static Future<void> eliminarPaciente(String id) async {

    _pacientes.removeWhere((p) => p.id == id);

    // si eliminamos el paciente activo
    if (_activo?.id == id) {

      if (_pacientes.isNotEmpty) {
        _activo = _pacientes.first;
        await guardarActivo(_activo!);
      } else {
        _activo = null;

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_keyActivo);
      }
    }

    await _guardarLista();
  }

  /*══════════════════════════════════════════════*/
  /// Limpiar todos los pacientes y activo
  static Future<void> limpiarTodo() async {

    _pacientes.clear();
    _activo = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPacientes);
    await prefs.remove(_keyActivo);
  }
}

/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
