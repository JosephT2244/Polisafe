/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfHelper {
  static Future<void> openPdf(
    BuildContext context, {
    required String assetPath,
    required String title,
    int page = 1,
  }) async {
    if (kIsWeb) {
      final uri = Uri.parse(assetPath);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir el PDF';
      }
    } else {
      final file = await _copyAssetToTemp(assetPath);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PdfViewerScreen(
            filePath: file.path,
            title: title,
            initialPage: page,
          ),
        ),
      );
    }
  }

  static Future<File> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }
}

/*──────────────────── VISOR PDF (APP) ────────────────────*/

class _PdfViewerScreen extends StatelessWidget {
  final String filePath;
  final String title;
  final int initialPage;

  const _PdfViewerScreen({
    required this.filePath,
    required this.title,
    required this.initialPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF660033),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        defaultPage: initialPage - 1,
      ),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
