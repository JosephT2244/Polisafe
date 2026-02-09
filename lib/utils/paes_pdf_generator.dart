/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/


import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/paes_model.dart';

class PaesPdfGenerator {
  // ───────────────── GENERADOR ─────────────────

  static Future<Uint8List> generate(PaesModel p) async {
    final pdf = pw.Document();

    // ────────── Cargar logo desde assets ──────────
    pw.MemoryImage? logoImage;

    try {
      final logoBytes = await rootBundle.load("assets/images/logo.jpg");
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    // ────────── Colores institucionales ──────────
    final PdfColor primaryColor = PdfColor.fromInt(0xFF78003C);
    final PdfColor secondaryColor = PdfColor.fromInt(0xFF222222);
    final PdfColor softGray = PdfColor.fromInt(0xFFF3F3F3);

    // ────────── Estilos ──────────
    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: primaryColor,
    );

    final subtitleStyle = pw.TextStyle(
      fontSize: 11,
      color: secondaryColor,
    );

    final sectionStyle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: primaryColor,
    );

    final labelStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: secondaryColor,
    );

    final valueStyle = pw.TextStyle(
      fontSize: 10,
      color: secondaryColor,
    );

    // ───────────────────────── PORTADA ─────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 40),

              if (logoImage != null)
                pw.Container(
                  width: 130,
                  height: 130,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(18),
                  ),
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                ),

              pw.SizedBox(height: 30),

              pw.Text("POLISAFE", style: titleStyle),
              pw.SizedBox(height: 6),

              pw.Text(
                "Sistema Profesional de Enfermería",
                style: subtitleStyle,
              ),

              pw.SizedBox(height: 15),
              pw.Divider(thickness: 1.5, color: primaryColor),
              pw.SizedBox(height: 25),

              pw.Text(
                "PROCESO DE ATENCIÓN DE ENFERMERÍA (PAES)",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryColor,
                ),
              ),

              pw.SizedBox(height: 25),

              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: softGray,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoLine("Paciente:", p.patientName),
                    _infoLine("Edad:", "${p.age} años"),
                    _infoLine("Sexo:", p.gender),
                    _infoLine("Tipo de sangre:", p.bloodType),
                    _infoLine("Expediente:", p.expediente),
                    _infoLine("Servicio / Área:", p.service),
                    _infoLine("Cama:", p.bed),
                    _infoLine(
                      "Fecha de valoración:",
                      _formatDate(p.evaluationDateTime),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              pw.Text(
                "Documento generado automáticamente en POLISAFE",
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),

              pw.SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    // ───────────────────────── DOCUMENTO ─────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(30, 40, 30, 40),
        header: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 28,
                        height: 28,
                        margin: const pw.EdgeInsets.only(right: 8),
                        child: pw.Image(logoImage),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "POLISAFE",
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.Text(
                          "",
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Text(
                  "Página ${context.pageNumber} / ${context.pagesCount}",
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Paciente: ${p.patientName}",
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.Text(
                  "Generado por POLISAFE",
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
        build: (context) => [
          pw.SizedBox(height: 10),

          // ───────── DATOS GENERALES ─────────
          _sectionBox(
            "DATOS GENERALES DEL PACIENTE",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Nombre", p.patientName],
                ["Edad", "${p.age} años"],
                ["Sexo", p.gender],
                ["Tipo de sangre", p.bloodType],
                ["Fecha nacimiento", _formatDate(p.birthDate)],
                ["Expediente", p.expediente],
                ["Servicio", p.service],
                ["Cama", p.bed],
                ["Fecha de valoración", _formatDate(p.evaluationDateTime)],
              ]),
            ],
          ),

          // ───────── DATOS CLÍNICOS ─────────
          _sectionBox(
            "DATOS CLÍNICOS GENERALES",
            sectionStyle,
            [
              _paragraph(
                "Diagnóstico médico",
                p.medicalDiagnosis,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Motivo de ingreso",
                p.admissionReason,
                labelStyle,
                valueStyle,
              ),
              _paragraph("Alergias", p.allergies, labelStyle, valueStyle),
              _paragraph(
                "Medicamentos prescritos",
                p.medications,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Signos vitales (texto general)",
                p.vitalSigns,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── SIGNOS VITALES DETALLADOS ─────────
          _sectionBox(
            "SIGNOS VITALES DETALLADOS",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Temperatura", "${p.temperature} °C"],
                ["Frecuencia cardiaca", "${p.heartRate} lpm"],
                ["Frecuencia respiratoria", "${p.respiratoryRate} rpm"],
                ["Presión sistólica", "${p.systolicPressure} mmHg"],
                ["Presión diastólica", "${p.diastolicPressure} mmHg"],
                ["SpO2", "${p.spo2} %"],
                ["Glucosa", "${p.glucose} mg/dL"],
              ]),
            ],
          ),

          // ───────── ANTECEDENTES ─────────
          _sectionBox(
            "ANTECEDENTES",
            sectionStyle,
            [
              _paragraph(
                "Patológicos",
                p.personalAntecedents,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "No patológicos",
                p.nonPathAntecedents,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Familiares y sociales",
                p.familySocialAntecedents,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── ANTROPOMETRÍA ─────────
          _sectionBox(
            "ANTROPOMETRÍA",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Peso", "${p.weight} kg"],
                ["Talla", "${p.height} m"],
                ["Circunferencia abdominal", "${p.abdominalCircumference} cm"],
                ["IMC", p.bmi.toStringAsFixed(2)],
                ["Superficie corporal (BSA)", p.bsa.toStringAsFixed(2)],
              ]),
            ],
          ),

          // ───────── ESCALAS ─────────
          _sectionBox(
            "ESCALAS DE VALORACIÓN",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Dolor (EVA)", p.evaPain.toString()],
                ["Riesgo de caídas (Downton)", p.downtonFallRisk.toString()],
                ["Riesgo úlceras (Braden)", p.bradenUlcerRisk.toString()],
                ["Estado de conciencia (Glasgow)", p.glasgow.toString()],
              ]),
            ],
          ),

          // ───────── VALORACIÓN ─────────
          _sectionBox(
            "VALORACIÓN DE ENFERMERÍA",
            sectionStyle,
            [
              _paragraph(
                " valoración",
                p.valoracionContent,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Datos subjetivos",
                p.subjectiveData,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Datos objetivos",
                p.objectiveData,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Estado general",
                p.generalState,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Estado mental",
                p.mentalState,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Nivel de conciencia",
                p.consciousnessLevel,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── PATRONES ─────────
          _sectionBox(
            "PATRONES FUNCIONALES",
            sectionStyle,
            [
              _paragraph("Oxigenación", p.oxygenation, labelStyle, valueStyle),
              _paragraph(
                "Nutrición e hidratación",
                p.feedingHydration,
                labelStyle,
                valueStyle,
              ),
              _paragraph("Eliminación", p.elimination, labelStyle, valueStyle),
              _paragraph("Movilidad", p.mobility, labelStyle, valueStyle),
              _paragraph(
                "Higiene / descanso",
                p.hygieneRest,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Estado emocional",
                p.emotionalState,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── CÁLCULOS CLÍNICOS ─────────
          _sectionBox(
            "CÁLCULOS CLÍNICOS",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Dosis adulto", p.adultDose.toStringAsFixed(2)],
                ["Dosis pediátrica", p.pediatricDose.toStringAsFixed(2)],
                ["PAM", p.pam.toStringAsFixed(2)],
                ["Goteo", p.drip],
                ["Pérdidas insensibles", p.insensibleLosses],
              ]),
            ],
          ),

          // ───────── PROBLEMAS ─────────
          _sectionBox(
            "PROBLEMAS DETECTADOS",
            sectionStyle,
            [
              _bulletBox("Problemas reales", p.actualProblems),
              pw.SizedBox(height: 10),
              _bulletBox("Problemas potenciales", p.potentialProblems),
            ],
          ),

          // ───────── NANDA ─────────
          _sectionBox(
            "DIAGNÓSTICO NANDA",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Código", p.nandaCode],
                ["Etiqueta", p.nandaLabel],
                ["Etiología", p.etiology],
                ["Signos y síntomas", p.signsSymptoms],
                ["Prioridad", p.priority],
              ]),
              pw.SizedBox(height: 6),
              _paragraph(
                " diagnóstico",
                p.diagnosticoContent,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── NOC ─────────
          _sectionBox(
            "OBJETIVOS NOC",
            sectionStyle,
            [
              _bulletBox("Lista de objetivos NOC", p.nocObjectives),
            ],
          ),

          // ───────── NIC ─────────
          _sectionBox(
            "INTERVENCIONES NIC",
            sectionStyle,
            [
              _bulletBox("Lista de intervenciones NIC", p.nicInterventions),
            ],
          ),

          // ───────── PLANIFICACIÓN ─────────
          _sectionBox(
            "PLANIFICACIÓN",
            sectionStyle,
            [
              _paragraph(
                "Contenido general",
                p.planificacionContent,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── EJECUCIÓN ─────────
          _sectionBox(
            "EJECUCIÓN",
            sectionStyle,
            [
              _bulletBox("Notas de ejecución", p.executionNotes),
              pw.SizedBox(height: 8),
              _paragraph(
                "Contenido general",
                p.ejecucionContent,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── EVALUACIÓN ─────────
          _sectionBox(
            "EVALUACIÓN",
            sectionStyle,
            [
              _paragraph(
                "Contenido general",
                p.evaluacionContent,
                labelStyle,
                valueStyle,
              ),
              _paragraph(
                "Resultado final",
                p.evaluation,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── REGISTROS ─────────
          _sectionBox(
            "REGISTROS DE ENFERMERÍA",
            sectionStyle,
            [
              _bulletBox("Notas y registros", p.nursingNotes),
            ],
          ),

          // ───────── EDUCACIÓN ─────────
          _sectionBox(
            "EDUCACIÓN AL PACIENTE",
            sectionStyle,
            [
              _paragraph(
                "Educación",
                p.patientEducation,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── CONTINGENCIA ─────────
          _sectionBox(
            "PLAN DE CONTINGENCIA",
            sectionStyle,
            [
              _paragraph(
                "Contingencia",
                p.contingencyPlan,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── CRITERIOS EGRESO ─────────
          _sectionBox(
            "CRITERIOS DE EGRESO",
            sectionStyle,
            [
              _paragraph(
                "Criterios",
                p.dischargeCriteria,
                labelStyle,
                valueStyle,
              ),
            ],
          ),

          // ───────── FIRMA ─────────
          _sectionBox(
            "FIRMA Y RESPONSABLE",
            sectionStyle,
            [
              _tableTwoColumns(labelStyle, valueStyle, [
                ["Enfermero(a)", p.nurseName],
                ["Categoría", p.nurseCategory],
                ["Turno", p.shift],
                ["Firma", p.signature],
              ]),
            ],
          ),

          pw.SizedBox(height: 20),
        ],
      ),
    );

    return pdf.save();
  }

  // ───────────────── UTILIDADES ─────────────────

  static String _formatDate(String value) {
    if (value.trim().isEmpty) return "—";

    try {
      final d = DateTime.tryParse(value);
      if (d == null) return value;

      return "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";
    } catch (_) {
      return value;
    }
  }

  static pw.Widget _infoLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? "—" : value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionBox(
    String title,
    pw.TextStyle sectionStyle,
    List<pw.Widget> children,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(
              title,
              style: sectionStyle,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _paragraph(
    String label,
    String value,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: labelStyle),
          pw.SizedBox(height: 3),
          pw.Text(value.trim().isEmpty ? "—" : value.trim(), style: valueStyle),
        ],
      ),
    );
  }

  static pw.Widget _bulletBox(String title, List<String> items) {
    if (items.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text("—", style: const pw.TextStyle(fontSize: 10)),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items.map((e) => pw.Bullet(text: e)).toList(),
        ),
      ],
    );
  }

  static pw.Widget _tableTwoColumns(
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
    List<List<String>> rows,
  ) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(4),
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      children: rows.map((r) {
        return pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(r[0], style: labelStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                r[1].trim().isEmpty ? "—" : r[1],
                style: valueStyle,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
