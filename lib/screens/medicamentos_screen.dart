/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*──────────────────────── MODELO ────────────────────────*/

class Medicamento {
  final String nombre;
  final String categoria;
  final String? grupo;
  final String mecanismo;
  final String? mecanismoImg;
  final List<String> indicaciones;
  final String? indicacionesImg;
  final List<String> reacciones;
  final List<String>? reaccionesImgs;
  final List<String> contraindicaciones;
  final List<String>? contraImgs;
  final String? nombreImagen;

  Medicamento({
    required this.nombre,
    required this.categoria,
    this.grupo,
    required this.mecanismo,
    this.mecanismoImg,
    required this.indicaciones,
    this.indicacionesImg,
    required this.reacciones,
    this.reaccionesImgs,
    required this.contraindicaciones,
    this.contraImgs,
    this.nombreImagen,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      nombre: json['nombre'],
      categoria: json['categoria'],
      grupo: json['grupo'],
      mecanismo: json['mecanismo_accion'],
      mecanismoImg: json['mecanismo_imagen'],
      indicaciones: List<String>.from(json['indicaciones_terapeuticas'] ?? []),
      indicacionesImg: json['indicaciones_imagen'],
      reacciones: List<String>.from(json['reacciones_adversas'] ?? []),
      reaccionesImgs: json['reacciones_imagenes'] != null
          ? List<String>.from(json['reacciones_imagenes'])
          : [],
      contraindicaciones: List<String>.from(json['contraindicaciones'] ?? []),
      contraImgs: json['contra_imagenes'] != null
          ? List<String>.from(json['contra_imagenes'])
          : [],
      nombreImagen: json['nombre_imagenes'] != null
          ? (json['nombre_imagenes'] is String
              ? json['nombre_imagenes']
              : (json['nombre_imagenes'] as List).first)
          : null,
    );
  }
}

/*──────────────────────── SCREEN ────────────────────────*/

class MedicamentosScreen extends StatefulWidget {
  const MedicamentosScreen({super.key});

  @override
  State<MedicamentosScreen> createState() => _MedicamentosScreenState();
}

class _MedicamentosScreenState extends State<MedicamentosScreen> {
  int selectedSection = 0;
  String searchQuery = '';
  List<Medicamento> medicamentos = [];
  Set<String> favoritos = {};
  late SharedPreferences prefs;

  final List<String> sections = [
    'Favoritos',
    'Fármacos',
    'Anticoagulantes',
    'Soluciones e Hidratación',
    'Corticosteroides',
    'Protectores gástricos',
  ];

  @override
  void initState() {
    super.initState();
    cargarMedicamentos();
    cargarFavoritos();
  }

  Future<void> cargarMedicamentos() async {
    final data = await rootBundle.loadString('assets/data/medicamentos.json');
    final decoded = json.decode(data);
    setState(() {
      medicamentos = (decoded['medicamentos'] as List)
          .map((e) => Medicamento.fromJson(e))
          .toList();
    });
  }

  Future<void> cargarFavoritos() async {
    prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favoritos') ?? [];
    setState(() {
      favoritos = favList.toSet();
    });
  }

  Future<void> guardarFavoritos() async {
    await prefs.setStringList('favoritos', favoritos.toList());
  }

  void toggleFavorito(String nombre) {
    setState(() {
      if (favoritos.contains(nombre)) {
        favoritos.remove(nombre);
      } else {
        favoritos.add(nombre);
      }
    });
    guardarFavoritos();
  }

  //──────────────────── FILTRAR MEDICAMENTOS ────────────────────
  List<Medicamento> filtrarMedicamentos(String seccion) {
    List<Medicamento> filtrados;

    if (seccion == 'Favoritos') {
      filtrados =
          medicamentos.where((m) => favoritos.contains(m.nombre)).toList();
    } else {
      filtrados = medicamentos.where((m) {
        final coincideSeccion = m.categoria == seccion;
        final coincideBusqueda = m.nombre.toLowerCase().contains(searchQuery) ||
            (m.grupo?.toLowerCase().contains(searchQuery) ?? false) ||
            m.indicaciones.any((i) => i.toLowerCase().contains(searchQuery));
        return coincideSeccion && coincideBusqueda;
      }).toList();
    }

    // Favoritos primero
    filtrados.sort((a, b) {
      final aFav = favoritos.contains(a.nombre) ? 0 : 1;
      final bFav = favoritos.contains(b.nombre) ? 0 : 1;
      return aFav.compareTo(bFav);
    });

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) =>
                setState(() => searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Buscar medicamento',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Secciones
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final selected = index == selectedSection;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(sections[index]),
                  selected: selected,
                  selectedColor: const Color(0xFF660033),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) => setState(() => selectedSection = index),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Lista de medicamentos
        Expanded(
          child: medicamentos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : buildContenido(),
        ),
      ],
    );
  }

  Widget buildContenido() {
    final seccionActual = sections[selectedSection];
    final filtrados = filtrarMedicamentos(seccionActual);

    if (filtrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron medicamentos',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) => MedicamentoCard(
        medicamento: filtrados[index],
        isFavorito: favoritos.contains(filtrados[index].nombre),
        onFavoritoToggle: () => toggleFavorito(filtrados[index].nombre),
      ),
    );
  }
}

/*──────────────────────── CARD MEDICAMENTO ────────────────────────*/

class MedicamentoCard extends StatelessWidget {
  final Medicamento medicamento;
  final bool isFavorito;
  final VoidCallback onFavoritoToggle;

  const MedicamentoCard({
    super.key,
    required this.medicamento,
    this.isFavorito = false,
    required this.onFavoritoToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen nombre medicamento
            if (medicamento.nombreImagen != null)
              SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/medicamentos/${medicamento.nombreImagen}',
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Título + favorito
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    medicamento.nombre,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF660033)),
                  ),
                ),
                IconButton(
                  onPressed: onFavoritoToggle,
                  icon: Icon(
                    isFavorito ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              medicamento.grupo ?? medicamento.categoria,
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 28),
            // Secciones con imágenes grandes
            MedicamentoSection(
              titulo: 'Mecanismo de acción',
              texto: medicamento.mecanismo,
              imageNames: medicamento.mecanismoImg != null &&
                      medicamento.mecanismoImg!.isNotEmpty
                  ? [medicamento.mecanismoImg!]
                  : [],
              imageSize: 180,
            ),
            MedicamentoSection.list(
              titulo: 'Indicaciones terapéuticas',
              items: medicamento.indicaciones,
              imageNames: medicamento.indicacionesImg != null &&
                      medicamento.indicacionesImg!.isNotEmpty
                  ? [medicamento.indicacionesImg!]
                  : [],
              imageSize: 180,
            ),
            MedicamentoSection.list(
              titulo: 'Reacciones adversas',
              items: medicamento.reacciones,
              imageNames: medicamento.reaccionesImgs ?? [],
              imageSize: 180,
            ),
            MedicamentoSection.list(
              titulo: 'Contraindicaciones',
              items: medicamento.contraindicaciones,
              imageNames: medicamento.contraImgs ?? [],
              imageSize: 180,
            ),
          ],
        ),
      ),
    );
  }
}

/*──────────────────────── SECCIÓN ────────────────────────*/

class MedicamentoSection extends StatelessWidget {
  final String titulo;
  final String? texto;
  final List<String>? items;
  final List<String> imageNames;
  final double imageSize;

  const MedicamentoSection({
    super.key,
    required this.titulo,
    this.texto,
    this.items,
    required this.imageNames,
    this.imageSize = 110,
  });

  factory MedicamentoSection.list({
    required String titulo,
    required List<String> items,
    List<String>? imageNames,
    double imageSize = 110,
  }) {
    return MedicamentoSection(
      titulo: titulo,
      items: items,
      imageNames: imageNames ?? [],
      imageSize: imageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (texto != null)
            Text(texto!)
          else if (items != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items!
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $e'),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 6),
          if (imageNames.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: imageNames
                    .map((name) => ImageItem(name: name, size: imageSize))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/*──────────────────────── IMAGE ITEM ────────────────────────*/

class ImageItem extends StatelessWidget {
  final String name;
  final double size;
  const ImageItem({super.key, required this.name, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/medicamentos/$name',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
