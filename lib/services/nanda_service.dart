/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'dart:convert';
import 'package:flutter/services.dart';

class NandaService {
  static List<Map<String, dynamic>> _data = [];

  static Future<void> load() async {
    final jsonString =
        await rootBundle.loadString('assets/data/nanda_2026.json');
    final List<dynamic> decoded = json.decode(jsonString);
    _data = decoded.cast<Map<String, dynamic>>();
  }

  static List<Map<String, dynamic>> search(String query) {
    if (query.trim().isEmpty) return [];

    return _data.where((n) {
      final text =
          '${n['codigo']} ${n['etiqueta']} ${n['definicion']}'.toLowerCase();
      return text.contains(query.toLowerCase());
    }).toList();
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
