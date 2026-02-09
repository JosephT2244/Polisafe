/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/*══════════════════════════════════════════════*/

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {

  // ───────── STATES
  bool _notificaciones = true;
  bool _darkMode = false;
  bool _sonido = true;
  bool _vibracion = true;
  bool _autoLogin = true;

  String _userName = "Usuario";

  /*══════════════════════════════════════════════*/

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /*══════════════════════════════════════════════*/

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _notificaciones = prefs.getBool("notificaciones") ?? true;
    _darkMode = prefs.getBool("dark") ?? false;
    _sonido = prefs.getBool("sonido") ?? true;
    _vibracion = prefs.getBool("vibracion") ?? true;
    _autoLogin = prefs.getBool("autoLogin") ?? true;

    _userName = AuthService.getUserName();

    setState(() {});
  }

  /*══════════════════════════════════════════════*/

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /*══════════════════════════════════════════════*/

  Future<void> _changeName() async {
    final controller = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cambiar nombre"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nuevo nombre",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("user", controller.text.trim());

              _userName = controller.text.trim();
              setState(() {});
              Navigator.pop(context);

              _show("Nombre actualizado");
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  /*══════════════════════════════════════════════*/

  Future<void> _changePassword() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cambiar contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña actual",
              ),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nueva contraseña",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Guardar"),
            onPressed: () {
              Navigator.pop(context);
              _show("Contraseña actualizada");
            },
          ),
        ],
      ),
    );
  }

  /*══════════════════════════════════════════════*/

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.setDarkMode(false);

    setState(() {
      _notificaciones = true;
      _darkMode = false;
      _sonido = true;
      _vibracion = true;
      _autoLogin = true;
      _userName = "Usuario";
    });

    _show("Datos locales eliminados");
  }

  /*══════════════════════════════════════════════*/

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /*══════════════════════════════════════════════*/

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /*══════════════════════════════════════════════*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /*════════════════ HEADER ════════════════*/

          const Text(
            "Configuración",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF660033),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Sesión activa: $_userName",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 20),

          /*════════════════ PERFIL ════════════════*/

          _section("Perfil"),

          _card(
            icon: Icons.person,
            title: "Cambiar nombre",
            subtitle: "Modificar nombre mostrado",
            onTap: _changeName,
          ),

          _card(
            icon: Icons.lock,
            title: "Cambiar contraseña",
            subtitle: "Actualizar contraseña local",
            onTap: _changePassword,
          ),

          /*════════════════ SISTEMA ════════════════*/

          _section("Sistema"),

          _switch(
            "Modo oscuro",
            "Tema oscuro del sistema",
            _darkMode,
            (v) async {

              setState(() => _darkMode = v);

              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);

              await themeProvider.setDarkMode(v);

              _show("Tema aplicado");
            },
          ),

          _switch(
            "Notificaciones",
            "Recordatorios clínicos",
            _notificaciones,
            (v) async {
              setState(() => _notificaciones = v);
              await _saveBool("notificaciones", v);
            },
          ),

          _switch(
            "Sonido",
            "Efectos del sistema",
            _sonido,
            (v) async {
              setState(() => _sonido = v);
              await _saveBool("sonido", v);
            },
          ),

          _switch(
            "Vibración",
            "Respuesta háptica",
            _vibracion,
            (v) async {
              setState(() => _vibracion = v);
              await _saveBool("vibracion", v);
            },
          ),

          _switch(
            "Inicio automático",
            "Mantener sesión iniciada",
            _autoLogin,
            (v) async {
              setState(() => _autoLogin = v);
              await _saveBool("autoLogin", v);
            },
          ),

          /*════════════════ DATOS ════════════════*/

          _section("Datos"),

          _card(
            icon: Icons.delete_forever,
            title: "Borrar datos locales",
            subtitle: "Restablecer aplicación",
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirmar"),
                  content: const Text("Se eliminarán todos los datos locales."),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Eliminar"),
                      onPressed: () {
                        Navigator.pop(context);
                        _clearData();
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          /*════════════════ INFORMACIÓN ════════════════*/

          _section("Información"),

          _card(
            icon: Icons.info,
            title: "Acerca de PoliSafe",
            subtitle: "Versión 1.0",
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("PoliSafe"),
                  content: const Text(
                    "Sistema profesional de apoyo clínico "
                    "para estudiantes y personal de enfermería.",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cerrar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),

          /*════════════════ DESARROLLADORES ════════════════*/

          _card(
            icon: Icons.code,
            title: "Desarrolladores",
            subtitle: "Equipo de desarrollo",
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Desarrolladores"),
                  content: const Text(
                    "• Joseph Ubaldo Trejo Hernandez\n"
                    "• Sofia Cruz García\n"
                    "• María Guadalupe Cortes Cano",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cerrar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),

          /*════════════════ SESIÓN ════════════════*/

          _section("Sesión"),

          _card(
            icon: Icons.logout,
            title: "Cerrar sesión",
            subtitle: "Salir del sistema",
            color: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Cerrar sesión"),
                  content: const Text("¿Deseas salir del sistema?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Salir"),
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /*════════════════ COMPONENTES ════════════════*/

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = const Color(0xFF660033),
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        activeThumbColor: const Color(0xFF660033),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/*══════════════════════════════════════════════
 Un código de: Joseph Ubaldo Trejo Hernandez
══════════════════════════════════════════════*/
