/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'dart:convert';
import 'package:flutter/services.dart';

class NicService {
  static List<Map<String, dynamic>> _data = [];

  static Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/data/nic_2024.json');
    _data = List<Map<String, dynamic>>.from(json.decode(jsonStr));
  }

  static List<Map<String, dynamic>> search(String query) {
    query = query.toLowerCase();
    return _data.where((n) =>
      n['codigo'].contains(query) ||
      n['etiqueta'].toLowerCase().contains(query)
    ).toList();
  }

  static List<Map<String, dynamic>> byNanda(String nandaCode) {
    return _data.where((n) =>
      (n['relacion_nanda'] as List).contains(nandaCode)
    ).toList();
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
