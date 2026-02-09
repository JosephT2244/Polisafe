/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*════════════════════════ MODELO ════════════════════════*/

enum NotiPrioridad { alta, media, baja }

class NotificacionModel {
  final String id;
  final String titulo;
  final String mensaje;
  final IconData icono;
  final DateTime fecha;
  final NotiPrioridad prioridad;
  bool leida;

  NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.icono,
    required this.fecha,
    required this.prioridad,
    this.leida = false,
  });
}

/*════════════════════════ PROVIDER ════════════════════════*/

class NotificacionesProvider extends ChangeNotifier {
  final List<NotificacionModel> _notificaciones = [
    NotificacionModel(
      id: '1',
      titulo: 'Recordatorio clínico',
      mensaje: 'Verificar dosis antes de administrar medicamento.',
      icono: Icons.medical_services,
      fecha: DateTime.now(),
      prioridad: NotiPrioridad.media,
    ),
    NotificacionModel(
      id: '2',
      titulo: 'Área quirúrgica',
      mensaje: 'Confirmar esterilidad del instrumental.',
      icono: Icons.local_hospital,
      fecha: DateTime.now(),
      prioridad: NotiPrioridad.alta,
    ),
    NotificacionModel(
      id: '3',
      titulo: 'PAES',
      mensaje: 'Actualizar valoración del paciente.',
      icono: Icons.list_alt,
      fecha: DateTime.now(),
      prioridad: NotiPrioridad.baja,
    ),
  ];

  NotiPrioridad? _filtro;

  List<NotificacionModel> get notificaciones {
    if (_filtro == null) return _notificaciones;
    return _notificaciones.where((n) => n.prioridad == _filtro).toList();
  }

  int get noLeidas =>
      _notificaciones.where((n) => !n.leida).length;

  void marcarLeida(String id) {
    final n = _notificaciones.firstWhere((e) => e.id == id);
    if (!n.leida) {
      n.leida = true;
      notifyListeners();
    }
  }

  void marcarTodasLeidas() {
    for (var n in _notificaciones) {
      n.leida = true;
    }
    notifyListeners();
  }

  void eliminar(String id) {
    _notificaciones.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setFiltro(NotiPrioridad? prioridad) {
    _filtro = prioridad;
    notifyListeners();
  }
}

/*════════════════════════ SCREEN ════════════════════════*/

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificacionesProvider(),
      child: const _NotificacionesView(),
    );
  }
}

/*════════════════════════ VIEW ════════════════════════*/

class _NotificacionesView extends StatelessWidget {
  const _NotificacionesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificacionesProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF660033),
        title: Text('Notificaciones (${provider.noLeidas})'),
        actions: [
          IconButton(
            tooltip: 'Marcar todas como leídas',
            icon: const Icon(Icons.done_all),
            onPressed:
                provider.noLeidas == 0 ? null : provider.marcarTodasLeidas,
          ),
          PopupMenuButton<NotiPrioridad?>(
            tooltip: 'Filtrar',
            onSelected: provider.setFiltro,
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Todas')),
              PopupMenuItem(value: NotiPrioridad.alta, child: Text('Alta')),
              PopupMenuItem(value: NotiPrioridad.media, child: Text('Media')),
              PopupMenuItem(value: NotiPrioridad.baja, child: Text('Baja')),
            ],
          ),
        ],
      ),
      body: provider.notificaciones.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notificaciones.length,
              itemBuilder: (_, i) =>
                  _NotificacionCard(n: provider.notificaciones[i]),
            ),
    );
  }
}

/*════════════════════════ CARD ════════════════════════*/

class _NotificacionCard extends StatelessWidget {
  final NotificacionModel n;

  const _NotificacionCard({required this.n});

  Color get _color {
    switch (n.prioridad) {
      case NotiPrioridad.alta:
        return Colors.red;
      case NotiPrioridad.media:
        return Colors.orange;
      case NotiPrioridad.baja:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificacionesProvider>();

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.eliminar(n.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: n.leida ? 2 : 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _color.withOpacity(0.15),
            child: Icon(n.icono, color: _color),
          ),
          title: Text(
            n.titulo,
            style: TextStyle(
              fontWeight: n.leida ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text(n.mensaje),
          trailing: n.leida
              ? null
              : Icon(Icons.circle, size: 10, color: _color),
          onTap: () => provider.marcarLeida(n.id),
        ),
      ),
    );
  }
}

/*════════════════════════ EMPTY STATE ════════════════════════*/

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Todo está en orden 👌'),
        ],
      ),
    );
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
