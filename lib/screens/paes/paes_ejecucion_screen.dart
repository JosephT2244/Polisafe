/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'package:flutter/material.dart';

import '../../../models/paes_historial.dart';
import '../../../services/paes_historial_service.dart';

class PaesEjecucionScreen extends StatefulWidget {
  const PaesEjecucionScreen({super.key});

  @override
  State<PaesEjecucionScreen> createState() => _PaesEjecucionScreenState();
}

class _PaesEjecucionScreenState extends State<PaesEjecucionScreen> {
  final List<Map<String, dynamic>> intervenciones = [];
  static const Color _iconGrey = Color.fromARGB(200, 255, 255, 255);

  void _guardarEjecucion() {
    final buffer = StringBuffer();

    buffer.writeln('Intervenciones de Enfermería (NIC):');
    for (var i in intervenciones) {
      buffer.writeln(
          '${i['codigo']} ${i['etiqueta']} | ${i['descripcion']} | Frecuencia: ${i['frecuencia']} | Turno: ${i['turno']} | Responsable: ${i['responsable']} | Realizada: ${i['realizada']} | Fecha: ${i['fecha']}');
    }

    // Guardamos en historial
    PaesHistorialService.agregar(
      PaesHistorialItem(
        etapa: PaesEtapa.ejecucion,
        contenido: buffer.toString(),
        fecha: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ejecución guardada en el historial')),
    );
  }

  /*──────────────────── MOSTRAR HISTORIAL ────────────────────*/
  void _verHistorial() {
    final historial = PaesHistorialService.obtenerPorEtapa(PaesEtapa.ejecucion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Historial de Ejecuciones'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay ejecuciones guardadas.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (_, index) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Ejecución ${index + 1}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ejecución de Enfermería',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
          ),
        ),
        backgroundColor: const Color(0xFF660033),
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

            _sectionTitle('Intervenciones de Enfermería (NIC)'),
            _addIntervencion(),

            const SizedBox(height: 16),
            _listaIntervenciones(),

            const SizedBox(height: 30),

              // ---------- BOTÓN GUARDAR ----------
              SizedBox(
                width: double.infinity, // ocupa todo el ancho disponible (más largo)
                child: ElevatedButton.icon(
                  onPressed: _guardarEjecucion,
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

  Widget _addIntervencion() {
    final TextEditingController nicCodigoCtrl = TextEditingController();
    final TextEditingController nicEtiquetaCtrl = TextEditingController();
    final TextEditingController descripcionCtrl = TextEditingController();
    final TextEditingController responsableCtrl = TextEditingController();
    final TextEditingController observacionesCtrl = TextEditingController();

    String frecuencia = 'Cada turno';
    String turno = 'Matutino';
    bool realizada = true;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nicCodigoCtrl,
              decoration: const InputDecoration(labelText: 'Código NIC'),
            ),
            TextField(
              controller: nicEtiquetaCtrl,
              decoration: const InputDecoration(labelText: 'Etiqueta NIC'),
            ),
            TextField(
              controller: descripcionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción de la intervención',
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: frecuencia,
                    items: const [
                      DropdownMenuItem(value: 'Cada turno', child: Text('Cada turno')),
                      DropdownMenuItem(value: 'Cada 8 h', child: Text('Cada 8 h')),
                      DropdownMenuItem(value: 'Cada 12 h', child: Text('Cada 12 h')),
                      DropdownMenuItem(value: 'PRN', child: Text('PRN')),
                      DropdownMenuItem(value: 'Única vez', child: Text('Única vez')),
                    ],
                    onChanged: (v) => frecuencia = v!,
                    decoration: const InputDecoration(labelText: 'Frecuencia'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: turno,
                    items: const [
                      DropdownMenuItem(value: 'Matutino', child: Text('Matutino')),
                      DropdownMenuItem(value: 'Vespertino', child: Text('Vespertino')),
                      DropdownMenuItem(value: 'Nocturno', child: Text('Nocturno')),
                    ],
                    onChanged: (v) => turno = v!,
                    decoration: const InputDecoration(labelText: 'Turno'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: responsableCtrl,
              decoration: const InputDecoration(
                labelText: 'Responsable (nombre o categoría)',
              ),
            ),

            TextField(
              controller: observacionesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observaciones / Evidencia',
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              value: realizada,
              onChanged: (v) => setState(() => realizada = v),
              title: const Text('Intervención realizada'),
              activeThumbColor: const Color(0xFF660033),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF660033), size: 30),
                onPressed: () {
                  if (descripcionCtrl.text.isNotEmpty) {
                    setState(() {
                      intervenciones.add({
                        'codigo': nicCodigoCtrl.text,
                        'etiqueta': nicEtiquetaCtrl.text,
                        'descripcion': descripcionCtrl.text,
                        'frecuencia': frecuencia,
                        'turno': turno,
                        'responsable': responsableCtrl.text,
                        'observaciones': observacionesCtrl.text,
                        'realizada': realizada,
                        'fecha': DateTime.now(),
                      });
                    });

                    // Limpiamos campos
                    nicCodigoCtrl.clear();
                    nicEtiquetaCtrl.clear();
                    descripcionCtrl.clear();
                    responsableCtrl.clear();
                    observacionesCtrl.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaIntervenciones() {
    if (intervenciones.isEmpty) {
      return const Text('No hay intervenciones registradas');
    }

    return Column(
      children: intervenciones.map((i) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(
              i['realizada'] ? Icons.check_circle : Icons.error,
              color: i['realizada'] ? Colors.green : Colors.red,
            ),
            title: Text(
              '${i['codigo']} ${i['etiqueta']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${i['descripcion']}\n'
              'Frecuencia: ${i['frecuencia']} • Turno: ${i['turno']}\n'
              'Responsable: ${i['responsable']}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() => intervenciones.remove(i)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
