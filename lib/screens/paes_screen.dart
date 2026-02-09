/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'package:flutter/material.dart';

import 'paes_generator.dart';
import '../utils/pdf_helper.dart';

// Etapas del PAES
import 'paes/paes_valoracion_screen.dart';
import 'paes/paes_diagnostico_screen.dart';
import 'paes/paes_planificacion_screen.dart';
import 'paes/paes_ejecucion_screen.dart';
import 'paes/paes_evaluacion_screen.dart';

// Historial
import '../services/paes_historial_service.dart';
import '../models/paes_historial.dart';
import 'package:intl/intl.dart';

// Servicios JSON
import '../services/nanda_service.dart';
import '../services/nic_service.dart';
import '../services/noc_service.dart';

class PaesScreen extends StatefulWidget {
  const PaesScreen({super.key});

  @override
  State<PaesScreen> createState() => _PaesScreenState();
}

class _PaesScreenState extends State<PaesScreen> {
  bool _cargandoDatos = true;
  bool _errorCarga = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  Future<void> _cargarCatalogos() async {
    try {
      await Future.wait([
        NandaService.load(),
        NicService.load(),
        NocService.load(),
      ]);

      if (!mounted) return;

      setState(() {
        _cargandoDatos = false;
        _errorCarga = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoDatos = false;
        _errorCarga = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF660033),
          ),
        ),
      );
    }

    if (_errorCarga) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Color(0xFF660033)),
                const SizedBox(height: 14),
                const Text(
                  'Error al cargar NANDA, NIC o NOC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verifica que los archivos JSON existan en assets y estén declarados correctamente en pubspec.yaml.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cargandoDatos = true;
                      _errorCarga = false;
                    });
                    _cargarCatalogos();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF660033),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF660033),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Proceso de Atención de Enfermería',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'El Proceso de Atención de Enfermería (PAES) es un método sistemático '
              'que permite brindar cuidados organizados, científicos y seguros, '
              'centrados en las necesidades del paciente.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            const Text(
              'Etapas del PAES',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                _PaesCard(
                  title: 'Valoración',
                  subtitle: 'Recopilación de datos',
                  icon: Icons.assignment,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaesValoracionScreen(),
                      ),
                    );
                  },
                ),
                _PaesCard(
                  title: 'Diagnóstico',
                  subtitle: 'Diagnósticos NANDA',
                  icon: Icons.search,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaesDiagnosticoScreen(),
                      ),
                    );
                  },
                ),
                _PaesCard(
                  title: 'Planificación',
                  subtitle: 'Resultados NOC / NIC',
                  icon: Icons.rule,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaesPlanificacionScreen(
                          nandaCodigo: '00000',
                        ),
                      ),
                    );
                  },
                ),
                _PaesCard(
                  title: 'Ejecución',
                  subtitle: 'Intervenciones NIC',
                  icon: Icons.play_circle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaesEjecucionScreen(),
                      ),
                    );
                  },
                ),
                _PaesCard(
                  title: 'Evaluación',
                  subtitle: 'Seguimiento',
                  icon: Icons.check_circle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaesEvaluacionScreen(),
                      ),
                    );
                  },
                ),
                _PaesCard(
                  title: 'Historial',
                  subtitle: 'Ver registros previos',
                  icon: Icons.history,
                  onTap: () {
                    final historial =
                        PaesHistorialService.todos().reversed.toList();

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Historial de PAES'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: historial.isEmpty
                              ? const Text('No hay registros guardados.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: historial.length,
                                  itemBuilder: (context, index) {
                                    final item = historial[index];
                                    return Card(
                                      color: Colors.grey.shade100,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          _iconoPorEtapa(item.etapa),
                                          color: const Color(0xFF660033),
                                        ),
                                        title: Text(
                                          _nombreEtapa(item.etapa),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${DateFormat('dd/MM/yyyy – HH:mm').format(item.fecha)}\n${item.contenido.length > 50 ? '${item.contenido.substring(0, 50)}...' : item.contenido}',
                                        ),
                                        isThreeLine: true,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title:
                                                  Text(_nombreEtapa(item.etapa)),
                                              content: SingleChildScrollView(
                                                child: Text(item.contenido),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cerrar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PdfHelper.openPdf(
                        context,
                        assetPath: 'assets/data/nanda.pdf',
                        title: 'Diagnósticos NANDA',
                      );
                    },
                    icon: const Icon(Icons.book),
                    label: const Text('NANDA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 220),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PdfHelper.openPdf(
                        context,
                        assetPath: 'assets/data/noc.pdf',
                        title: 'Resultados NOC',
                      );
                    },
                    icon: const Icon(Icons.bookmark),
                    label: const Text('NOC'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 220),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PdfHelper.openPdf(
                        context,
                        assetPath: 'assets/data/nic.pdf',
                        title: 'Intervenciones NIC',
                      );
                    },
                    icon: const Icon(Icons.library_books),
                    label: const Text('NIC'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 220),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaesGeneratorScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo PAE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 220),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _nombreEtapa(PaesEtapa etapa) {
    switch (etapa) {
      case PaesEtapa.valoracion:
        return 'Valoración';
      case PaesEtapa.diagnostico:
        return 'Diagnóstico';
      case PaesEtapa.planificacion:
        return 'Planificación';
      case PaesEtapa.ejecucion:
        return 'Ejecución';
      case PaesEtapa.evaluacion:
        return 'Evaluación';
      case PaesEtapa.quirurgico:
        return 'quirurgico';
    }
  }

  static IconData _iconoPorEtapa(PaesEtapa etapa) {
    switch (etapa) {
      case PaesEtapa.valoracion:
        return Icons.assignment;
      case PaesEtapa.diagnostico:
        return Icons.search;
      case PaesEtapa.planificacion:
        return Icons.rule;
      case PaesEtapa.ejecucion:
        return Icons.play_circle;
      case PaesEtapa.evaluacion:
        return Icons.check_circle;
      case PaesEtapa.quirurgico:
        return Icons.check_circle;
    }
  }
}

class _PaesCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PaesCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF660033)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
