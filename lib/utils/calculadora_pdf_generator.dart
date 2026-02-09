/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/*══════════════════════════════════════════════*/

class CalculadoraPdfGenerator {
  /*══════════════════════════════════════════════*/
  /// Generar PDF profesional para cualquier cálculo
  ///
  /// Ejemplo de uso:
  /// final bytes = await CalculadoraPdfGenerator.generate(
  ///   titulo: "Cálculo de Dosis",
  ///   paciente: "Juan Pérez",
  ///   contenido: {
  ///     "Peso": "70 kg",
  ///     "Medicamento": "Paracetamol",
  ///     "Dosis indicada": "500 mg",
  ///     "Resultado": "1 tableta cada 8 horas",
  ///   },
  /// );
  static Future<Uint8List> generate({
    required String titulo,
    required String paciente,
    required Map<String, String> contenido,
    String? subtitulo,
    String? descripcion,
    String? enfermero,
    String? categoria,
    String? turno,
    String? hospital,
    DateTime? fecha,
  }) async {
    final pdf = pw.Document();

    // ─────────── Cargar Logo ───────────
    pw.MemoryImage? logoImage;

    try {
      final data = await rootBundle.load("assets/images/logo.jpg");
      final bytes = data.buffer.asUint8List();
      logoImage = pw.MemoryImage(bytes);
    } catch (_) {
      // Si el logo falla, no se rompe el PDF
      logoImage = null;
    }

    final DateTime fechaFinal = fecha ?? DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              "Página ${context.pageNumber} / ${context.pagesCount}",
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
          );
        },
        build: (context) => [
          _header(
            logo: logoImage,
            titulo: titulo,
            subtitulo: subtitulo,
            hospital: hospital,
          ),

          pw.SizedBox(height: 14),

          _sectionTitle("DATOS GENERALES"),
          _infoRow("Paciente", paciente),
          _infoRow("Fecha", _formatDate(fechaFinal)),
          _infoRow("Hora", _formatTime(fechaFinal)),

          if (descripcion != null && descripcion.trim().isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _sectionTitle("DESCRIPCIÓN"),
            _paragraph(descripcion),
          ],

          pw.SizedBox(height: 14),
          _sectionTitle("RESULTADO DEL CÁLCULO"),

          pw.SizedBox(height: 6),
          _table(contenido),

          pw.SizedBox(height: 20),
          pw.Divider(thickness: 0.7),

          pw.SizedBox(height: 10),
          _sectionTitle("RESPONSABLE"),

          _infoRow("Enfermero(a)", enfermero ?? "—"),
          _infoRow("Categoría", categoria ?? "—"),
          _infoRow("Turno", turno ?? "—"),

          pw.SizedBox(height: 18),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
              color: PdfColors.grey100,
            ),
            child: pw.Text(
              "Documento generado automáticamente por POLISAFE.\n"
              "Este reporte es informativo y no sustituye criterio clínico.",
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /*══════════════════════════════════════════════*/
  /// HEADER PROFESIONAL
  static pw.Widget _header({
    required pw.MemoryImage? logo,
    required String titulo,
    String? subtitulo,
    String? hospital,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey500,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null)
            pw.Container(
              width: 52,
              height: 52,
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 52,
              height: 52,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey500),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                "LOGO",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),

          pw.SizedBox(width: 14),

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "POLISAFE",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),

                pw.SizedBox(height: 2),

                pw.Text(
                  titulo.trim().isEmpty ? "Reporte" : titulo,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                if (subtitulo != null && subtitulo.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    subtitulo,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],

                if (hospital != null && hospital.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    hospital,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*══════════════════════════════════════════════*/
  /// TITULO DE SECCIÓN
  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  /*══════════════════════════════════════════════*/
  /// FILA DE INFO SIMPLE
  static pw.Widget _infoRow(String label, String value) {
    final safeValue = value.trim().isEmpty ? "—" : value.trim();

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              safeValue,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /*══════════════════════════════════════════════*/
  /// PÁRRAFO
  static pw.Widget _paragraph(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Text(
        text.trim().isEmpty ? "—" : text.trim(),
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  /*══════════════════════════════════════════════*/
  /// TABLA DE RESULTADOS
  static pw.Widget _table(Map<String, String> data) {
    if (data.isEmpty) {
      return pw.Text("—");
    }

    final rows = data.entries.map((e) {
      final key = e.key.trim().isEmpty ? "Dato" : e.key.trim();
      final value = e.value.trim().isEmpty ? "—" : e.value.trim();

      return pw.TableRow(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: PdfColors.grey300,
              width: 0.7,
            ),
          ),
        ),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: pw.Text(
              key,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      );
    }).toList();

    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1.2),
          1: const pw.FlexColumnWidth(2.2),
        },
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: PdfColors.grey300, width: 0.7),
        ),
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey200,
            ),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  "Campo",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  "Resultado",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }

  /*══════════════════════════════════════════════*/
  static String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(dt.day)}/${two(dt.month)}/${dt.year}";
  }

  static String _formatTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(dt.hour)}:${two(dt.minute)}";
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

