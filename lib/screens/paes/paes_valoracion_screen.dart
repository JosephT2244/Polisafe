/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Historial
import '../../../models/paes_historial.dart';
import '../../../services/paes_historial_service.dart';

class PaesValoracionScreen extends StatefulWidget {
  const PaesValoracionScreen({super.key});

  @override
  State<PaesValoracionScreen> createState() => _PaesValoracionScreenState();
}

class _PaesValoracionScreenState extends State<PaesValoracionScreen> {
  final _formKey = GlobalKey<FormState>();

  // ───── Controllers ─────
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();
  final TextEditingController expedienteCtrl = TextEditingController();
  final TextEditingController camaCtrl = TextEditingController();
  final TextEditingController servicioCtrl = TextEditingController();

  final TextEditingController motivoIngresoCtrl = TextEditingController();
  final TextEditingController dxMedicoCtrl = TextEditingController();
  final TextEditingController antecedentesCtrl = TextEditingController();
  final TextEditingController alergiasCtrl = TextEditingController();
  final TextEditingController medicamentosCtrl = TextEditingController();

  final TextEditingController subjetivosCtrl = TextEditingController();
  final TextEditingController objetivosCtrl = TextEditingController();

  final TextEditingController pesoCtrl = TextEditingController();
  final TextEditingController tallaCtrl = TextEditingController();
  final TextEditingController taCtrl = TextEditingController();
  final TextEditingController fcCtrl = TextEditingController();
  final TextEditingController frCtrl = TextEditingController();
  final TextEditingController tempCtrl = TextEditingController();
  final TextEditingController spo2Ctrl = TextEditingController();
  final TextEditingController glucosaCtrl = TextEditingController();

  static const Color _iconGrey = Color.fromARGB(200, 255, 255, 255);

  // Nuevo controlador para especificar sexo cuando se elige "Otro"
  final TextEditingController customSexoCtrl = TextEditingController();

  DateTime? fechaValoracion;
  String sexo = 'Masculino';
  String estadoConciencia = 'Alerta';

  // Nuevo campo para tipo de sangre
  String tipoSangre = 'Desconocido';

  // ───────── FORMATO AUTOMÁTICO TA 120/80 ─────────
  void _formatearTA(String value) {
    String limpio = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (limpio.length > 3) {
      limpio = '${limpio.substring(0, 3)}/${limpio.substring(3)}';
    }

    if (limpio.length > 7) {
      limpio = limpio.substring(0, 7);
    }

    if (taCtrl.text != limpio) {
      taCtrl.value = TextEditingValue(
        text: limpio,
        selection: TextSelection.collapsed(offset: limpio.length),
      );
    }
  }

  void _guardarValoracion() {
    if (!_formKey.currentState!.validate()) return;

    // Si sexo == 'Otro', tomar lo especificado en customSexoCtrl si no está vacío
    final displaySexo = sexo == 'Otro' && customSexoCtrl.text.trim().isNotEmpty
        ? customSexoCtrl.text.trim()
        : sexo;

    final contenido = '''
Identificación:
Nombre: ${nombreCtrl.text}
Edad: ${edadCtrl.text}
Expediente: ${expedienteCtrl.text}
Cama: ${camaCtrl.text}
Servicio: ${servicioCtrl.text}
Sexo: $displaySexo
Tipo de sangre: $tipoSangre
Fecha: ${fechaValoracion != null ? DateFormat('dd/MM/yyyy').format(fechaValoracion!) : ''}

Datos clínicos generales:
Diagnóstico médico: ${dxMedicoCtrl.text}
Motivo de ingreso: ${motivoIngresoCtrl.text}
Antecedentes: ${antecedentesCtrl.text}
Alergias: ${alergiasCtrl.text}
Medicamentos actuales: ${medicamentosCtrl.text}

Signos vitales:
TA: ${taCtrl.text}, FC: ${fcCtrl.text}, FR: ${frCtrl.text}, Temp: ${tempCtrl.text}, SpO2: ${spo2Ctrl.text}, Glucosa: ${glucosaCtrl.text}

Antropometría:
Peso: ${pesoCtrl.text}, Talla: ${tallaCtrl.text}

Valoración neurológica:
Estado de conciencia: $estadoConciencia

Datos subjetivos:
${subjetivosCtrl.text}

Datos objetivos:
${objetivosCtrl.text}
''';

    PaesHistorialService.agregar(
      PaesHistorialItem(
        etapa: PaesEtapa.valoracion,
        contenido: contenido,
        fecha: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Valoración guardada en el historial')),
    );
  }

  /*──────────────────── MOSTRAR HISTORIAL ────────────────────*/
  void _verHistorial() {
    final historial = PaesHistorialService.obtenerPorEtapa(PaesEtapa.valoracion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Historial de Valoraciones'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay valoraciones registradas.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (_, index) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Valoración ${index + 1}'),
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
          'Valoración de Enfermería',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Identificación del paciente'),
              _text(nombreCtrl, 'Nombre completo'),
              _row([_number(edadCtrl, 'Edad'), _dropdownSexo()]),

              // Si el usuario selecciona 'Otro', mostrar campo para especificar
              if (sexo == 'Otro') ...[
                const SizedBox(height: 8),
                _text(customSexoCtrl, 'Sexo (especifique)'),
              ],

              // Dropdown para tipo de sangre
              const SizedBox(height: 8),
              _dropdownTipoSangre(),

              _row([_text(expedienteCtrl, 'Expediente'), _text(camaCtrl, 'Cama')]),
              _text(servicioCtrl, 'Servicio'),
              _datePicker(),

              _sectionTitle('Datos clínicos generales'),
              _textArea(dxMedicoCtrl, 'Diagnóstico médico'),
              _textArea(motivoIngresoCtrl, 'Motivo de ingreso'),
              _textArea(antecedentesCtrl, 'Antecedentes relevantes'),
              _textArea(alergiasCtrl, 'Alergias'),
              _textArea(medicamentosCtrl, 'Medicamentos actuales'),

              _sectionTitle('Signos vitales'),
              _row([_taField(), _number(fcCtrl, 'FC')]),
              _row([_number(frCtrl, 'FR'), _number(tempCtrl, 'Temp °C')]),
              _row([_number(spo2Ctrl, 'SpO₂ %'), _number(glucosaCtrl, 'Glucosa')]),

              _sectionTitle('Antropometría'),
              _row([_number(pesoCtrl, 'Peso (kg)'), _number(tallaCtrl, 'Talla (m)')]),

              _sectionTitle('Valoración neurológica'),
              _dropdownConciencia(),

              _sectionTitle('Datos subjetivos'),
              _textArea(subjetivosCtrl, 'Lo que refiere el paciente'),

              _sectionTitle('Datos objetivos'),
              _textArea(objetivosCtrl, 'Lo observado por enfermería'),

              const SizedBox(height: 30),

              // ---------- BOTÓN GUARDAR ----------
              SizedBox(
                width: double.infinity, // ocupa todo el ancho disponible (más largo)
                child: ElevatedButton.icon(
                  onPressed: _guardarValoracion,
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
      ),
    );
  }

  /*──────────────────── WIDGETS ────────────────────*/
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _text(TextEditingController c, String label) => TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
      );

  Widget _number(TextEditingController c, String label) => TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );

  Widget _textArea(TextEditingController c, String label) => TextFormField(
        controller: c,
        maxLines: 3,
        decoration: InputDecoration(labelText: label),
      );

  Widget _row(List<Widget> children) => Row(
        children: children
            .map(
              (e) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: e,
                ),
              ),
            )
            .toList(),
      );

  Widget _dropdownSexo() => DropdownButtonFormField<String>(
        initialValue: sexo,
        items: const [
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
        ],
        onChanged: (v) => setState(() {
          sexo = v!;
          // Si cambias a otra opción distinta de 'Otro', limpia el customSexo
          if (sexo != 'Otro') customSexoCtrl.clear();
        }),
        decoration: const InputDecoration(labelText: 'Sexo'),
      );

  Widget _dropdownTipoSangre() => DropdownButtonFormField<String>(
        initialValue: tipoSangre,
        items: const [
          DropdownMenuItem(value: 'A+', child: Text('A+')),
          DropdownMenuItem(value: 'A-', child: Text('A-')),
          DropdownMenuItem(value: 'B+', child: Text('B+')),
          DropdownMenuItem(value: 'B-', child: Text('B-')),
          DropdownMenuItem(value: 'AB+', child: Text('AB+')),
          DropdownMenuItem(value: 'AB-', child: Text('AB-')),
          DropdownMenuItem(value: 'O+', child: Text('O+')),
          DropdownMenuItem(value: 'O-', child: Text('O-')),
          DropdownMenuItem(value: 'Desconocido', child: Text('Desconocido')),
        ],
        onChanged: (v) => setState(() => tipoSangre = v!),
        decoration: const InputDecoration(labelText: 'Tipo de sangre'),
      );

  Widget _dropdownConciencia() => DropdownButtonFormField<String>(
        initialValue: estadoConciencia,
        items: const [
          DropdownMenuItem(value: 'Alerta', child: Text('Alerta')),
          DropdownMenuItem(value: 'Somnoliento', child: Text('Somnoliento')),
          DropdownMenuItem(value: 'Estupor', child: Text('Estupor')),
          DropdownMenuItem(value: 'Coma', child: Text('Coma')),
        ],
        onChanged: (v) => setState(() => estadoConciencia = v!),
        decoration: const InputDecoration(labelText: 'Estado de conciencia'),
      );

  Widget _datePicker() => TextFormField(
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Fecha de valoración'),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDate: DateTime.now(),
          );
          if (date != null) setState(() => fechaValoracion = date);
        },
        controller: TextEditingController(
          text: fechaValoracion == null
              ? ''
              : DateFormat('dd/MM/yyyy').format(fechaValoracion!),
        ),
      );

  // ───────── CAMPO TA CON "/" AUTOMÁTICO ─────────
  Widget _taField() => TextFormField(
        controller: taCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'TA'),
        onChanged: _formatearTA,
      );
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
