import 'dart:convert';
import 'package:flutter/services.dart';

class PaesDataLoader {
  static List<dynamic> nanda = [];
  static List<dynamic> nic = [];
  static List<dynamic> noc = [];

  static bool cargado = false;

  static Future<void> cargarTodo() async {
    if (cargado) return;

    try {
      final nandaData = await rootBundle.loadString('assets/data/nanda.json');
      final nicData = await rootBundle.loadString('assets/data/nic.json');
      final nocData = await rootBundle.loadString('assets/data/noc.json');

      final decodedNanda = json.decode(nandaData);
      final decodedNic = json.decode(nicData);
      final decodedNoc = json.decode(nocData);

      nanda = decodedNanda is List ? decodedNanda : (decodedNanda['nanda'] ?? []);
      nic = decodedNic is List ? decodedNic : (decodedNic['nic'] ?? []);
      noc = decodedNoc is List ? decodedNoc : (decodedNoc['noc'] ?? []);

      cargado = true;
    } catch (e) {
      nanda = [];
      nic = [];
      noc = [];
      cargado = false;
    }
  }

  static bool get listo {
    return cargado && nanda.isNotEmpty && nic.isNotEmpty && noc.isNotEmpty;
  }

  static void limpiar() {
    nanda = [];
    nic = [];
    noc = [];
    cargado = false;
  }
}
