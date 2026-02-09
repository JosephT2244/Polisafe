/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/

import 'dart:convert';

/*══════════════════════════════════════════════*/

class PaesHistorialItem {

  final PaesEtapa etapa;
  final String contenido;
  final DateTime fecha;

  PaesHistorialItem({
    required this.etapa,
    required this.contenido,
    required this.fecha,
  });

  /*══════════════════════════════════════════════*/
  /// Convertir objeto a Map (para guardarlo en JSON)
  Map<String, dynamic> toMap() {
    return {
      "etapa": etapa.name,
      "contenido": contenido,
      "fecha": fecha.toIso8601String(),
    };
  }

  /*══════════════════════════════════════════════*/
  /// Crear objeto desde Map (para cargarlo desde JSON)
  factory PaesHistorialItem.fromMap(Map<String, dynamic> map) {

    PaesEtapa etapaFinal = PaesEtapa.valoracion;

    try {
      etapaFinal = PaesEtapa.values.firstWhere(
        (e) => e.name == map["etapa"],
        orElse: () => PaesEtapa.valoracion,
      );
    } catch (_) {
      etapaFinal = PaesEtapa.valoracion;
    }

    DateTime fechaFinal = DateTime.now();

    try {
      fechaFinal = DateTime.tryParse(map["fecha"] ?? "") ?? DateTime.now();
    } catch (_) {
      fechaFinal = DateTime.now();
    }

    return PaesHistorialItem(
      etapa: etapaFinal,
      contenido: map["contenido"]?.toString() ?? "",
      fecha: fechaFinal,
    );
  }

  /*══════════════════════════════════════════════*/
  /// Convertir objeto a JSON
  String toJson() => jsonEncode(toMap());

  /*══════════════════════════════════════════════*/
  /// Crear objeto desde JSON
  factory PaesHistorialItem.fromJson(String source) {

    try {
      final decoded = jsonDecode(source);

      if (decoded is Map<String, dynamic>) {
        return PaesHistorialItem.fromMap(decoded);
      } else {
        return PaesHistorialItem(
          etapa: PaesEtapa.valoracion,
          contenido: "",
          fecha: DateTime.now(),
        );
      }

    } catch (_) {
      return PaesHistorialItem(
        etapa: PaesEtapa.valoracion,
        contenido: "",
        fecha: DateTime.now(),
      );
    }
  }

  /*══════════════════════════════════════════════*/
  /// Copia segura (útil para editar sin romper datos)
  PaesHistorialItem copyWith({
    PaesEtapa? etapa,
    String? contenido,
    DateTime? fecha,
  }) {
    return PaesHistorialItem(
      etapa: etapa ?? this.etapa,
      contenido: contenido ?? this.contenido,
      fecha: fecha ?? this.fecha,
    );
  }
}

/*══════════════════════════════════════════════*/

enum PaesEtapa {
  valoracion,
  diagnostico,
  planificacion,
  ejecucion,
  evaluacion,
  quirurgico,
}

/*══════════════════════════════════════════════*/

extension PaesEtapaExtension on PaesEtapa {

  /// Nombre bonito para mostrar en la app
  String get titulo {
    switch (this) {
      case PaesEtapa.valoracion:
        return "Valoración";
      case PaesEtapa.diagnostico:
        return "Diagnóstico";
      case PaesEtapa.planificacion:
        return "Planificación";
      case PaesEtapa.ejecucion:
        return "Ejecución";
      case PaesEtapa.evaluacion:
        return "Evaluación";
      case PaesEtapa.quirurgico:
        return "Quirúrgico";
    }
  }

  /// Color recomendado por etapa (por si lo usas después)
  String get colorKey {
    switch (this) {
      case PaesEtapa.valoracion:
        return "blue";
      case PaesEtapa.diagnostico:
        return "red";
      case PaesEtapa.planificacion:
        return "purple";
      case PaesEtapa.ejecucion:
        return "orange";
      case PaesEtapa.evaluacion:
        return "green";
      case PaesEtapa.quirurgico:
        return "teal";
    }
  }
}

/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/
