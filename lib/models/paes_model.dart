/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/
library;

import 'dart:convert';

class PaesModel {
  // ────────── Identificación del paciente ──────────
  final String patientName;
  final int age;
  final String gender;
  final String birthDate;
  final String expediente;
  final String service;
  final String bed;
  final String evaluationDateTime;

  // ────────── Datos clínicos generales ──────────
  final String medicalDiagnosis;
  final String admissionReason;
  final String personalAntecedents;
  final String nonPathAntecedents;
  final String allergies;
  final String medications;
  final String familySocialAntecedents;

  // ────────── Signos vitales (Texto general + variables separadas) ──────────
  final String vitalSigns;

  final double temperature; // °C
  final int heartRate; // lpm
  final int respiratoryRate; // rpm
  final int systolicPressure; // mmHg
  final int diastolicPressure; // mmHg
  final int spo2; // %
  final double glucose; // mg/dL

  // ────────── Datos antropométricos ──────────
  final double weight; // kg
  final double height; // m
  final double abdominalCircumference; // cm
  final double bmi; // IMC
  final double bsa; // superficie corporal

  // ────────── Tipo de sangre ──────────
  final String bloodType;

  // ────────── Valoración ──────────
  final String subjectiveData;
  final String objectiveData;
  final String generalState;
  final String mentalState;
  final String consciousnessLevel;

  // ────────── Escalas ──────────
  final int evaPain;
  final int downtonFallRisk;
  final int bradenUlcerRisk;
  final int glasgow;

  // ────────── Sistemas ──────────
  final String oxygenation;
  final String feedingHydration;
  final String elimination;
  final String mobility;
  final String hygieneRest;
  final String emotionalState;

  // ────────── Cálculos ──────────
  final double adultDose;
  final double pediatricDose;
  final double pam;
  final String drip;
  final String insensibleLosses;

  // ────────── Problemas ──────────
  final List<String> actualProblems;
  final List<String> potentialProblems;

  // ────────── Diagnóstico NANDA ──────────
  final String nandaCode;
  final String nandaLabel;
  final String etiology;
  final String signsSymptoms;
  final String priority;

  // ────────── NOC / NIC ──────────
  final List<String> nocObjectives;
  final List<String> nicInterventions;

  // ────────── Ejecución y evaluación ──────────
  final List<String> executionNotes;
  final List<String> nursingNotes;
  final String evaluation;

  // ────────── Educación y planes ──────────
  final String patientEducation;
  final String contingencyPlan;
  final String dischargeCriteria;

  // ────────── Firma ──────────
  final String nurseName;
  final String nurseCategory;
  final String shift;
  final String signature;

  // ────────── Contenidos completos de cada etapa ──────────
  final String valoracionContent;
  final String diagnosticoContent;
  final String planificacionContent;
  final String ejecucionContent;
  final String evaluacionContent;

  PaesModel({
    // Identificación
    required this.patientName,
    required this.age,
    required this.gender,
    required this.birthDate,
    required this.expediente,
    required this.service,
    required this.bed,
    required this.evaluationDateTime,

    // Datos generales
    required this.medicalDiagnosis,
    required this.admissionReason,
    required this.personalAntecedents,
    required this.nonPathAntecedents,
    required this.allergies,
    required this.medications,
    required this.familySocialAntecedents,

    // Signos vitales
    required this.vitalSigns,
    required this.temperature,
    required this.heartRate,
    required this.respiratoryRate,
    required this.systolicPressure,
    required this.diastolicPressure,
    required this.spo2,
    required this.glucose,

    // Antropometría
    required this.weight,
    required this.height,
    required this.abdominalCircumference,
    required this.bmi,
    required this.bsa,

    // Sangre
    required this.bloodType,

    // Valoración
    required this.subjectiveData,
    required this.objectiveData,
    required this.generalState,
    required this.mentalState,
    required this.consciousnessLevel,

    // Escalas
    required this.evaPain,
    required this.downtonFallRisk,
    required this.bradenUlcerRisk,
    required this.glasgow,

    // Sistemas
    required this.oxygenation,
    required this.feedingHydration,
    required this.elimination,
    required this.mobility,
    required this.hygieneRest,
    required this.emotionalState,

    // Cálculos
    required this.adultDose,
    required this.pediatricDose,
    required this.pam,
    required this.drip,
    required this.insensibleLosses,

    // Problemas
    required this.actualProblems,
    required this.potentialProblems,

    // NANDA
    required this.nandaCode,
    required this.nandaLabel,
    required this.etiology,
    required this.signsSymptoms,
    required this.priority,

    // NOC / NIC
    required this.nocObjectives,
    required this.nicInterventions,

    // Ejecución / evaluación
    required this.executionNotes,
    required this.nursingNotes,
    required this.evaluation,

    // Educación y planes
    required this.patientEducation,
    required this.contingencyPlan,
    required this.dischargeCriteria,

    // Firma
    required this.nurseName,
    required this.nurseCategory,
    required this.shift,
    required this.signature,

    // Contenidos
    this.valoracionContent = '',
    this.diagnosticoContent = '',
    this.planificacionContent = '',
    this.ejecucionContent = '',
    this.evaluacionContent = '',
  });

  // ----------------- Short helpers -----------------

  String get paciente => patientName;
  int get edad => age;

  String get valoracion =>
      'Subjetivo:\n$subjectiveData\n\nObjetivo:\n$objectiveData';

  String get diagnosticoNanda =>
      '$nandaCode - $nandaLabel\nEtiología: $etiology\nSignos: $signsSymptoms';

  String get resultadoNoc => nocObjectives.isEmpty
      ? ''
      : '• ${nocObjectives.join('\n• ')}';

  String get intervencionNic => nicInterventions.isEmpty
      ? ''
      : '• ${nicInterventions.join('\n• ')}';

  // ----------------- Serialization -----------------

  Map<String, dynamic> toMap() => {
        // Identificación
        'patientName': patientName,
        'age': age,
        'gender': gender,
        'birthDate': birthDate,
        'expediente': expediente,
        'service': service,
        'bed': bed,
        'evaluationDateTime': evaluationDateTime,

        // Datos generales
        'medicalDiagnosis': medicalDiagnosis,
        'admissionReason': admissionReason,
        'personalAntecedents': personalAntecedents,
        'nonPathAntecedents': nonPathAntecedents,
        'allergies': allergies,
        'medications': medications,
        'familySocialAntecedents': familySocialAntecedents,

        // Signos vitales
        'vitalSigns': vitalSigns,
        'temperature': temperature,
        'heartRate': heartRate,
        'respiratoryRate': respiratoryRate,
        'systolicPressure': systolicPressure,
        'diastolicPressure': diastolicPressure,
        'spo2': spo2,
        'glucose': glucose,

        // Antropometría
        'weight': weight,
        'height': height,
        'abdominalCircumference': abdominalCircumference,
        'bmi': bmi,
        'bsa': bsa,

        // Sangre
        'bloodType': bloodType,

        // Valoración
        'subjectiveData': subjectiveData,
        'objectiveData': objectiveData,
        'generalState': generalState,
        'mentalState': mentalState,
        'consciousnessLevel': consciousnessLevel,

        // Escalas
        'evaPain': evaPain,
        'downtonFallRisk': downtonFallRisk,
        'bradenUlcerRisk': bradenUlcerRisk,
        'glasgow': glasgow,

        // Sistemas
        'oxygenation': oxygenation,
        'feedingHydration': feedingHydration,
        'elimination': elimination,
        'mobility': mobility,
        'hygieneRest': hygieneRest,
        'emotionalState': emotionalState,

        // Cálculos
        'adultDose': adultDose,
        'pediatricDose': pediatricDose,
        'pam': pam,
        'drip': drip,
        'insensibleLosses': insensibleLosses,

        // Problemas
        'actualProblems': actualProblems,
        'potentialProblems': potentialProblems,

        // NANDA
        'nandaCode': nandaCode,
        'nandaLabel': nandaLabel,
        'etiology': etiology,
        'signsSymptoms': signsSymptoms,
        'priority': priority,

        // NOC / NIC
        'nocObjectives': nocObjectives,
        'nicInterventions': nicInterventions,

        // Ejecución y evaluación
        'executionNotes': executionNotes,
        'nursingNotes': nursingNotes,
        'evaluation': evaluation,

        // Educación
        'patientEducation': patientEducation,
        'contingencyPlan': contingencyPlan,
        'dischargeCriteria': dischargeCriteria,

        // Firma
        'nurseName': nurseName,
        'nurseCategory': nurseCategory,
        'shift': shift,
        'signature': signature,

        // Contenidos completos
        'valoracionContent': valoracionContent,
        'diagnosticoContent': diagnosticoContent,
        'planificacionContent': planificacionContent,
        'ejecucionContent': ejecucionContent,
        'evaluacionContent': evaluacionContent,
      };

  String toJson() => json.encode(toMap());

  // ----------------- From map (robust) -----------------
  factory PaesModel.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    List<String> toStringList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) {
        try {
          final parsed = json.decode(v);
          if (parsed is List) return parsed.map((e) => e.toString()).toList();
        } catch (_) {
          return [v];
        }
      }
      return [];
    }

    return PaesModel(
      patientName: (map['patientName'] ?? '').toString(),
      age: toInt(map['age']),
      gender: (map['gender'] ?? '').toString(),
      birthDate: (map['birthDate'] ?? '').toString(),
      expediente: (map['expediente'] ?? '').toString(),
      service: (map['service'] ?? '').toString(),
      bed: (map['bed'] ?? '').toString(),
      evaluationDateTime: (map['evaluationDateTime'] ?? '').toString(),

      medicalDiagnosis: (map['medicalDiagnosis'] ?? '').toString(),
      admissionReason: (map['admissionReason'] ?? '').toString(),
      personalAntecedents: (map['personalAntecedents'] ?? '').toString(),
      nonPathAntecedents: (map['nonPathAntecedents'] ?? '').toString(),
      allergies: (map['allergies'] ?? '').toString(),
      medications: (map['medications'] ?? '').toString(),
      familySocialAntecedents: (map['familySocialAntecedents'] ?? '').toString(),

      vitalSigns: (map['vitalSigns'] ?? '').toString(),
      temperature: toDouble(map['temperature']),
      heartRate: toInt(map['heartRate']),
      respiratoryRate: toInt(map['respiratoryRate']),
      systolicPressure: toInt(map['systolicPressure']),
      diastolicPressure: toInt(map['diastolicPressure']),
      spo2: toInt(map['spo2']),
      glucose: toDouble(map['glucose']),

      weight: toDouble(map['weight']),
      height: toDouble(map['height']),
      abdominalCircumference: toDouble(map['abdominalCircumference']),
      bmi: toDouble(map['bmi']),
      bsa: toDouble(map['bsa']),

      bloodType: (map['bloodType'] ?? '').toString(),

      subjectiveData: (map['subjectiveData'] ?? '').toString(),
      objectiveData: (map['objectiveData'] ?? '').toString(),
      generalState: (map['generalState'] ?? '').toString(),
      mentalState: (map['mentalState'] ?? '').toString(),
      consciousnessLevel: (map['consciousnessLevel'] ?? '').toString(),

      evaPain: toInt(map['evaPain']),
      downtonFallRisk: toInt(map['DowntonFallRisk']),
      bradenUlcerRisk: toInt(map['bradenUlcerRisk']),
      glasgow: toInt(map['glasgow']),

      oxygenation: (map['oxygenation'] ?? '').toString(),
      feedingHydration: (map['feedingHydration'] ?? '').toString(),
      elimination: (map['elimination'] ?? '').toString(),
      mobility: (map['mobility'] ?? '').toString(),
      hygieneRest: (map['hygieneRest'] ?? '').toString(),
      emotionalState: (map['emotionalState'] ?? '').toString(),

      adultDose: toDouble(map['adultDose']),
      pediatricDose: toDouble(map['pediatricDose']),
      pam: toDouble(map['pam']),
      drip: (map['drip'] ?? '').toString(),
      insensibleLosses: (map['insensibleLosses'] ?? '').toString(),

      actualProblems: toStringList(map['actualProblems']),
      potentialProblems: toStringList(map['potentialProblems']),

      nandaCode: (map['nandaCode'] ?? '').toString(),
      nandaLabel: (map['nandaLabel'] ?? '').toString(),
      etiology: (map['etiology'] ?? '').toString(),
      signsSymptoms: (map['signsSymptoms'] ?? '').toString(),
      priority: (map['priority'] ?? '').toString(),

      nocObjectives: toStringList(map['nocObjectives']),
      nicInterventions: toStringList(map['nicInterventions']),

      executionNotes: toStringList(map['executionNotes']),
      nursingNotes: toStringList(map['nursingNotes']),
      evaluation: (map['evaluation'] ?? '').toString(),

      patientEducation: (map['patientEducation'] ?? '').toString(),
      contingencyPlan: (map['contingencyPlan'] ?? '').toString(),
      dischargeCriteria: (map['dischargeCriteria'] ?? '').toString(),

      nurseName: (map['nurseName'] ?? '').toString(),
      nurseCategory: (map['nurseCategory'] ?? '').toString(),
      shift: (map['shift'] ?? '').toString(),
      signature: (map['signature'] ?? '').toString(),

      valoracionContent: (map['valoracionContent'] ?? '').toString(),
      diagnosticoContent: (map['diagnosticoContent'] ?? '').toString(),
      planificacionContent: (map['planificacionContent'] ?? '').toString(),
      ejecucionContent: (map['ejecucionContent'] ?? '').toString(),
      evaluacionContent: (map['evaluacionContent'] ?? '').toString(),
    );
  }

  factory PaesModel.fromJson(String source) =>
      PaesModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
