/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:polisafe/models/paes_historial.dart';

/*══════════════════════════════════════════════*/

class PaesHistorialService {
  static const String _key = "paes_historial";

  static final List<PaesHistorialItem> _historial = [];

  static bool _cargado = false;

  /*══════════════════════════════════════════════*/
  /// Cargar historial desde almacenamiento local
  static Future<void> cargar() async {
    if (_cargado) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_key);

      if (data == null || data.trim().isEmpty) {
        _historial.clear();
        _cargado = true;
        return;
      }

      final decoded = jsonDecode(data);

      if (decoded is! List) {
        _historial.clear();
        _cargado = true;
        return;
      }

      _historial.clear();

      for (var item in decoded) {
        try {
          if (item is Map<String, dynamic>) {
            _historial.add(PaesHistorialItem.fromMap(item));
          } else if (item is Map) {
            _historial.add(
              PaesHistorialItem.fromMap(Map<String, dynamic>.from(item)),
            );
          }
        } catch (_) {
          // Ignorar items corruptos sin romper el sistema
        }
      }

      _historial.sort((a, b) => b.fecha.compareTo(a.fecha));

      _cargado = true;
    } catch (_) {
      _historial.clear();
      _cargado = true;
    }
  }

  /*══════════════════════════════════════════════*/
  /// Guardar historial en almacenamiento local
  static Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> data =
          _historial.map((e) => e.toMap()).toList();

      await prefs.setString(_key, jsonEncode(data));
    } catch (_) {
      // No hacer nada, para evitar crasheos
    }
  }

  /*══════════════════════════════════════════════*/
  /// Agregar item al historial
  static Future<void> agregar(PaesHistorialItem item) async {
    await cargar();

    _historial.insert(0, item);

    if (_historial.length > 300) {
      _historial.removeRange(300, _historial.length);
    }

    await _guardar();
  }

  /*══════════════════════════════════════════════*/
  /// Agregar rápido (sin crear manualmente el objeto)
  static Future<void> agregarRapido({
    required PaesEtapa etapa,
    required String contenido,
    DateTime? fecha,
  }) async {
    await agregar(
      PaesHistorialItem(
        etapa: etapa,
        contenido: contenido,
        fecha: fecha ?? DateTime.now(),
      ),
    );
  }

  /*══════════════════════════════════════════════*/
  /// Obtener lista completa
  static List<PaesHistorialItem> todos() {
    return List.unmodifiable(_historial);
  }

  /*══════════════════════════════════════════════*/
  /// Obtener lista ordenada por fecha
  static List<PaesHistorialItem> todosOrdenados() {
    final copia = List<PaesHistorialItem>.from(_historial);

    copia.sort((a, b) => b.fecha.compareTo(a.fecha));

    return copia;
  }

  /*══════════════════════════════════════════════*/
  /// Eliminar item exacto
  static Future<void> eliminar(PaesHistorialItem item) async {
    await cargar();

    _historial.remove(item);

    await _guardar();
  }

  /*══════════════════════════════════════════════*/
  /// Eliminar por índice (más rápido y seguro en UI)
  static Future<void> eliminarPorIndice(int index) async {
    await cargar();

    if (index < 0 || index >= _historial.length) return;

    _historial.removeAt(index);

    await _guardar();
  }

  /*══════════════════════════════════════════════*/
  /// Filtrar por etapa
  static List<PaesHistorialItem> obtenerPorEtapa(PaesEtapa etapa) {
    final lista = _historial.where((item) => item.etapa == etapa).toList();

    lista.sort((a, b) => b.fecha.compareTo(a.fecha));

    return lista;
  }

  /*══════════════════════════════════════════════*/
  /// Obtener los últimos N elementos
  static List<PaesHistorialItem> ultimos(int cantidad) {
    if (cantidad <= 0) return [];

    if (_historial.length <= cantidad) {
      return List.unmodifiable(_historial);
    }

    return List.unmodifiable(_historial.take(cantidad));
  }

  /*══════════════════════════════════════════════*/
  /// Reemplazar historial completo (útil para sistema por pacientes)
  static Future<void> reemplazarHistorial(
      List<PaesHistorialItem> nuevo) async {
    await cargar();

    _historial.clear();
    _historial.addAll(nuevo);

    _historial.sort((a, b) => b.fecha.compareTo(a.fecha));

    await _guardar();
  }

  /*══════════════════════════════════════════════*/
  /// Limpiar historial completo
  static Future<void> limpiar() async {
    await cargar();

    _historial.clear();

    await _guardar();
  }

  /*══════════════════════════════════════════════*/
  /// Saber si ya está cargado el historial
  static bool get estaCargado => _cargado;
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
