/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'package:flutter/material.dart';

//  Historial
import '../../../models/paes_historial.dart';
import '../../../services/paes_historial_service.dart';

class PaesEvaluacionScreen extends StatefulWidget {
  const PaesEvaluacionScreen({super.key});

  @override
  State<PaesEvaluacionScreen> createState() => _PaesEvaluacionScreenState();
}

class _PaesEvaluacionScreenState extends State<PaesEvaluacionScreen> {
  final List<Map<String, dynamic>> evaluaciones = [];

  final TextEditingController conclusionCtrl = TextEditingController();
  final TextEditingController recomendacionesCtrl = TextEditingController();
  static const Color _iconGrey = Color.fromARGB(200, 255, 255, 255);

  String decision = 'Continuar plan';

  double puntuacionInicial = 1;
  double puntuacionFinal = 3;

  final TextEditingController nocCodigoCtrl = TextEditingController();
  final TextEditingController nocEtiquetaCtrl = TextEditingController();
  final TextEditingController indicadorCtrl = TextEditingController();

  void _guardarEvaluacion() {
    final buffer = StringBuffer();

    buffer.writeln('Evaluación de Resultados (NOC):');
    for (var e in evaluaciones) {
      buffer.writeln(
          '${e['codigo']} ${e['resultado']} | Indicador: ${e['indicador']} | Inicial: ${e['inicial']} → Final: ${e['final']} | Fecha: ${e['fecha']}');
    }

    buffer.writeln('\nConclusión de Enfermería:');
    buffer.writeln(conclusionCtrl.text);

    buffer.writeln('\nDecisión Clínica: $decision');

    buffer.writeln('\nRecomendaciones:');
    buffer.writeln(recomendacionesCtrl.text);

    // Agregamos al historial
    PaesHistorialService.agregar(
      PaesHistorialItem(
        etapa: PaesEtapa.evaluacion,
        contenido: buffer.toString(),
        fecha: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evaluación guardada en el historial')),
    );
  }

  /*──────────────────── MOSTRAR HISTORIAL ────────────────────*/
  void _verHistorial() {
    final historial = PaesHistorialService.obtenerPorEtapa(PaesEtapa.evaluacion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Historial de Evaluaciones'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay evaluaciones registradas.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (_, index) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Evaluación ${index + 1}'),
                      subtitle: Text(historial[index].contenido),
                    ),
                  ),
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
  }

  @override
  void dispose() {
    conclusionCtrl.dispose();
    recomendacionesCtrl.dispose();
    nocCodigoCtrl.dispose();
    nocEtiquetaCtrl.dispose();
    indicadorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Evaluación de Enfermería',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
          ),
        ),        backgroundColor: const Color(0xFF660033),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: _iconGrey,
            tooltip: 'Ver historial',
            onPressed: _verHistorial,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _sectionTitle('Evaluación de Resultados (NOC)'),
            _agregarEvaluacion(),

            const SizedBox(height: 16),
            _listaEvaluaciones(),

            const SizedBox(height: 24),

            _sectionTitle('Conclusión de Enfermería'),
            TextField(
              controller: conclusionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Redacta la conclusión clínica del cuidado otorgado',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle('Decisión Clínica'),
            DropdownButtonFormField<String>(
              initialValue: decision,
              items: const [
                DropdownMenuItem(value: 'Continuar plan', child: Text('Continuar plan')),
                DropdownMenuItem(value: 'Modificar plan', child: Text('Modificar plan')),
                DropdownMenuItem(value: 'Alta de enfermería', child: Text('Alta de enfermería')),
                DropdownMenuItem(value: 'Referir a otro servicio', child: Text('Referir a otro servicio')),
              ],
              onChanged: (v) => setState(() => decision = v!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle('Recomendaciones'),
            TextField(
              controller: recomendacionesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Indicaciones al paciente / familia / continuidad de cuidados',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

              // ---------- BOTÓN GUARDAR ----------
              SizedBox(
                width: double.infinity, // ocupa todo el ancho disponible (más largo)
                child: ElevatedButton.icon(
                  onPressed: _guardarEvaluacion,
                  icon: const Icon(
                    Icons.save,
                    color: Color(0xFF660033), // ícono en color institucional
                  ),
                  label: const Text(
                    'Guardar planificación',
                    style: TextStyle(
                      color: Color(0xFF660033),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F0E6), // crema
                    padding: const EdgeInsets.symmetric(
                      vertical: 16, // un poco más alto
                      horizontal: 22,
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /*──────────────────── WIDGETS ────────────────────*/

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _agregarEvaluacion() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nocCodigoCtrl,
              decoration: const InputDecoration(labelText: 'Código NOC'),
            ),
            TextField(
              controller: nocEtiquetaCtrl,
              decoration: const InputDecoration(labelText: 'Resultado NOC'),
            ),
            TextField(
              controller: indicadorCtrl,
              decoration: const InputDecoration(labelText: 'Indicador evaluado'),
            ),

            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntuación inicial: ${puntuacionInicial.toInt()}'),
                Slider(
                  value: puntuacionInicial,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: puntuacionInicial.toInt().toString(),
                  onChanged: (v) {
                    setState(() {
                      puntuacionInicial = v;
                    });
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntuación final: ${puntuacionFinal.toInt()}'),
                Slider(
                  value: puntuacionFinal,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: puntuacionFinal.toInt().toString(),
                  onChanged: (v) {
                    setState(() {
                      puntuacionFinal = v;
                    });
                  },
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF660033), size: 30),
                onPressed: () {
                  setState(() {
                    evaluaciones.add({
                      'codigo': nocCodigoCtrl.text,
                      'resultado': nocEtiquetaCtrl.text,
                      'indicador': indicadorCtrl.text,
                      'inicial': puntuacionInicial.toInt(),
                      'final': puntuacionFinal.toInt(),
                      'fecha': DateTime.now(),
                    });

                    // ✅ reiniciamos valores para siguiente registro
                    puntuacionInicial = 1;
                    puntuacionFinal = 3;
                  });

                  // Limpiamos los campos
                  nocCodigoCtrl.clear();
                  nocEtiquetaCtrl.clear();
                  indicadorCtrl.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaEvaluaciones() {
    if (evaluaciones.isEmpty) {
      return const Text('No hay evaluaciones registradas');
    }

    return Column(
      children: evaluaciones.map((e) {
        final mejora = e['final'] - e['inicial'];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(
              mejora > 0 ? Icons.trending_up : Icons.trending_flat,
              color: mejora > 0 ? Colors.green : Colors.orange,
            ),
            title: Text(
              '${e['codigo']} ${e['resultado']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Indicador: ${e['indicador']}\n'
              'Inicial: ${e['inicial']}  →  Final: ${e['final']}',
            ),
            isThreeLine: true,
            trailing: Text(
              mejora > 0 ? '+$mejora' : '0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: mejora > 0 ? Colors.green : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
