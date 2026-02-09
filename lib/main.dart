/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';

import 'screens/paes_screen.dart';
import 'screens/calculadora_screen.dart';
import 'screens/quirurgico_screen.dart';
import 'screens/estudio_screen.dart';
import 'screens/ajustes_screen.dart';
import 'screens/medicamentos_screen.dart';
import 'screens/notificaciones_screen.dart';

/// Color sólido para el fondo del sidebar/drawer (sin transparencia)
/// Un poco más oscuro que #F2F2F2: #E9E9E9
const Color sidebarGray = Color(0xFFE9E9E9);

/*════════════════════════ MAIN ═══════════════════════*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  runZonedGuarded(() {
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const PoliSafeApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Unhandled zone error: $error\n$stack');
  });
}

/*════════════════════════ APP ═══════════════════════*/

class PoliSafeApp extends StatelessWidget {
  const PoliSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PoliSafe',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF660033),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF660033),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
      builder: (context, widget) {
        return widget ??
            const Scaffold(
              body: Center(child: Text('Error al construir la UI')),
            );
      },
    );
  }
}

/*════════════════════════ MAIN SCREEN ═══════════════════════*/

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget?> _screens = List<Widget?>.filled(7, null, growable: false);

  bool _firebaseInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFirebase();
    });
  }

  Future<void> _initFirebase() async {
    if (_firebaseInitialized) return;
    _firebaseInitialized = true;

    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 10));
      debugPrint('Firebase inicializado correctamente');
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }

  Widget _getScreen(int index) {
    if (_screens[index] != null) return _screens[index]!;

    switch (index) {
      case 0:
        _screens[0] = const HomeContent();
        break;
      case 1:
        _screens[1] = CalculadoraScreen();
        break;
      case 2:
        _screens[2] = PaesScreen();
        break;
      case 3:
        _screens[3] = MedicamentosScreen();
        break;
      case 4:
        _screens[4] = QuirurgicoScreen();
        break;
      case 5:
        _screens[5] = EstudioScreen();
        break;
      case 6:
        _screens[6] = AjustesScreen();
        break;
      default:
        _screens[index] = const SizedBox.shrink();
    }

    return _screens[index]!;
  }

  void _goTo(int index) {
    if (!mounted) return;
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    try {
      Navigator.of(context).maybePop();
    } catch (e) {
      debugPrint('Navigator maybePop error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery values
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // define breakpoints
    final bool isLargeScreen = w >= 1200; // pantallas gigantes: mantiene sidebar abierto

    // scale factor relative to a typical desktop width (1366)
    // keep mobile appearance unchanged
    double scale = (w / 1366).clamp(0.8, 1.8);
    if (w <= 600) scale = 1.0;

    // AppBar toolbarHeight scales proportionally for larger screens
    final double baseToolbarPercent = (w <= 600) ? 0.14 : 0.11;
    final double toolbarHeight = (h * baseToolbarPercent * scale).clamp(56.0, 200.0);
    final double logoHeight = (toolbarHeight * 0.6).clamp(24.0, 140.0);
    final double iconSize = (24.0 * scale).clamp(16.0, 56.0);
    final double titleFontSize = (18.0 * scale).clamp(14.0, 48.0);

    final List<Widget> builtScreens = List.generate(
      _screens.length,
      (i) {
        if (i == _currentIndex) {
          return _getScreen(i);
        }
        return _screens[i] ?? const SizedBox.shrink();
      },
    );

    // width for persistent sidebar on giant screens
    // cambiado para hacerlo más delgado en pantallas grandes
    final double sidebarWidth = (w * 0.18).clamp(180.0, 300.0);

    // Build AppBar title widget (keeps mobile layout identical)
    Widget buildAppBarTitle() {
      if (w <= 600) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: toolbarHeight * 0.72,
              width: w * 0.90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: w * 0.067,
                  height: h * 0.08,
                  child: Image.asset(
                    'assets/images/ipn_logo.png',
                    cacheWidth: 180,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                SizedBox(width: w * 0.05),
                Text(
                  'PoliSafe',
                  style: TextStyle(
                    fontSize: w * 0.052,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: w * 0.05),
                SizedBox(
                  width: w * 0.117,
                  height: h * 0.08,
                  child: Image.asset(
                    'assets/images/cecyt16_logo.png',
                    cacheWidth: 200,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      // larger screens: proportional title
      final double containerWidth = (w * 0.86).clamp(200.0, w);
      return SizedBox(
        width: containerWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: toolbarHeight * 0.72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16 * scale),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0 * scale),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: logoHeight,
                      maxWidth: logoHeight * 1.6,
                    ),
                    child: Image.asset(
                      'assets/images/ipn_logo.png',
                      fit: BoxFit.contain,
                      cacheWidth: (180 * scale).round(),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(width: 12.0 * scale),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PoliSafe',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0 * scale),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: logoHeight,
                      maxWidth: logoHeight * 1.8,
                    ),
                    child: Image.asset(
                      'assets/images/cecyt16_logo.png',
                      fit: BoxFit.contain,
                      cacheWidth: (200 * scale).round(),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // If large screen: show permanent sidebar + content area
    if (isLargeScreen) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(toolbarHeight),
          child: AppBar(
            backgroundColor: const Color(0xFF660033),
            elevation: 6,
            centerTitle: true,
            toolbarHeight: toolbarHeight,
            title: buildAppBarTitle(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: iconSize,
                  color: const Color.fromARGB(200, 255, 255, 255),
                ),
                tooltip: 'Notificaciones',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificacionesScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  size: iconSize,
                  color: const Color.fromARGB(200, 255, 255, 255),
                ),
                tooltip: 'Ajustes',
                onPressed: () => _goTo(6),
              ),
              SizedBox(width: 8.0 * scale),
            ],
          ),
        ),
        // permanent sidebar on the left + main area
        body: Row(
          children: [
            // <-- menú lateral con fondo gris sólido fuera del header
            SizedBox(
              width: sidebarWidth,
              child: Container(
                color: sidebarGray,
                child: Column(
                  children: [
                    // Header morado (igual que main anterior)
                    _DrawerHeader(h: h),
                    // Items (scrollable)
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          buildDrawerTile(Icons.home, 'Inicio', () => _goTo(0)),
                          buildDrawerTile(Icons.calculate, 'Cálculos Clínicos', () => _goTo(1)),
                          buildDrawerTile(Icons.list_alt, 'PAES', () => _goTo(2)),
                          buildDrawerTile(Icons.healing, 'Farmacología', () => _goTo(3)),
                          buildDrawerTile(Icons.local_hospital, 'Área Quirúrgica', () => _goTo(4)),
                          buildDrawerTile(Icons.book, 'Estudio', () => _goTo(5)),
                          const Divider(),
                          buildDrawerTile(Icons.settings, 'Ajustes', () => _goTo(6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: builtScreens,
              ),
            ),
          ],
        ),
        // keep BottomNavigationBar for consistency (it will appear across large screens too)
        bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
          final double width = constraints.maxWidth;
          double iconSizeBn = 26.0;
          double fontSizeBn = 14.0;
          if (width >= 1600) {
            iconSizeBn = 32.0;
            fontSizeBn = 16.0;
          }
          return BottomNavigationBar(
            currentIndex: (_currentIndex > 3 ? 0 : _currentIndex),
            selectedItemColor: const Color(0xFF660033),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: (i) => _goTo(i),
            selectedLabelStyle: TextStyle(fontSize: fontSizeBn),
            unselectedLabelStyle: TextStyle(fontSize: fontSizeBn),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: iconSizeBn),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate, size: iconSizeBn),
                label: 'Cálculos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt, size: iconSizeBn),
                label: 'PAES',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.healing, size: iconSizeBn),
                label: 'Medicamentos',
              ),
            ],
          );
        }),
      );
    }

    // For small & medium screens: keep drawer behavior (drawer uses main anterior design)
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(toolbarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFF660033),
          elevation: 6,
          centerTitle: true,
          toolbarHeight: toolbarHeight,
          title: buildAppBarTitle(),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: iconSize,
                color: const Color.fromARGB(200, 255, 255, 255),
              ),
              tooltip: 'Notificaciones',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificacionesScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                size: iconSize,
                color: const Color.fromARGB(200, 255, 255, 255),
              ),
              tooltip: 'Ajustes',
              onPressed: () => _goTo(6),
            ),
            SizedBox(width: 6.0 * scale),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: sidebarGray,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _DrawerHeader(h: h),
              buildDrawerTile(Icons.home, 'Inicio', () => _goTo(0)),
              buildDrawerTile(Icons.calculate, 'Cálculos Clínicos', () => _goTo(1)),
              buildDrawerTile(Icons.list_alt, 'PAES', () => _goTo(2)),
              buildDrawerTile(Icons.healing, 'Farmacología', () => _goTo(3)),
              buildDrawerTile(Icons.local_hospital, 'Área Quirúrgica', () => _goTo(4)),
              buildDrawerTile(Icons.book, 'Estudio', () => _goTo(5)),
              const Divider(),
              buildDrawerTile(Icons.settings, 'Ajustes', () => _goTo(6)),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: builtScreens,
      ),
      bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // Keep mobile look identical: do not apply scaling under 600
        double iconSizeBn = 22.0;
        double fontSizeBn = 12.0;

        if (width >= 600 && width < 900) {
          iconSizeBn = 26.0;
          fontSizeBn = 14.0;
        } else if (width >= 900) {
          iconSizeBn = 30.0;
          fontSizeBn = 16.0;
        }

        return BottomNavigationBar(
          currentIndex: (_currentIndex > 3 ? 0 : _currentIndex),
          selectedItemColor: const Color(0xFF660033),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: (i) => _goTo(i),
          selectedLabelStyle: TextStyle(fontSize: fontSizeBn),
          unselectedLabelStyle: TextStyle(fontSize: fontSizeBn),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: iconSizeBn),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate, size: iconSizeBn),
              label: 'Cálculos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt, size: iconSizeBn),
              label: 'PAES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.healing, size: iconSizeBn),
              label: 'Medicamentos',
            ),
          ],
        );
      }),
    );
  }
}

/*════════════════════════ DRAWER HEADER (revisado para evitar overflows) ════════════════════════*/

class _DrawerHeader extends StatelessWidget {
  final double h;

  const _DrawerHeader({required this.h});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery and safe clamps to avoid extreme sizes
    final w = MediaQuery.of(context).size.width;
    final double headerHeight = (h * 0.28).clamp(140.0, 320.0);
    final double logoMaxHeight = (headerHeight * 0.55).clamp(60.0, 220.0);

    return Container(
      constraints: BoxConstraints(
        minHeight: 140,
        maxHeight: headerHeight,
      ),
      color: const Color(0xFF660033),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: (headerHeight * 0.05).clamp(8.0, 24.0)),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: logoMaxHeight,
                maxWidth: w * 0.9,
              ),
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.contain,
                cacheWidth: 350,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PoliSafe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sistema Profesional de Enfermería',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*════════════════════════ DRAWER TILE HELPERS (no change funcional) ════════════════════════*/

ListTile buildDrawerTile(
  IconData icon,
  String text,
  VoidCallback onTap,
) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFF660033)),
    title: Text(text),
    onTap: onTap,
  );
}

/*════════════════════════ HOME CONTENT ════════════════════════*/

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final main = context.findAncestorStateOfType<_MainScreenState>();
    final w = MediaQuery.of(context).size.width;

    // choose grid columns by width
    int crossAxisCount() {
      // Normal celular: 2 columnas (para la mayoría de móviles)
      // Breakpoints:
      // - >=1400: 4 columnas (pantallas grandes)
      // - >=1000: 3 columnas (laptops)
      // - >=350: 2 columnas (móviles y pequeños tablets)
      // - <350: 1 columna (dispositivos extremadamente estrechos)
      if (w >= 1400) return 4;
      if (w >= 1000) return 3;
      if (w >= 350) return 2;
      return 1;
    }

    // childAspectRatio tuned to avoid overlap and keep card height proportional
    double childAspectRatio() {
      if (w >= 1400) return 1.4;
      if (w >= 1000) return 1.2;
      if (w >= 700) return 1.0;
      // for narrow mobile columns, make cards a bit taller
      if (w >= 350) return 0.95;
      return 0.9;
    }

    final double heroImageHeight = (w * 0.35).clamp(160.0, 600.0);

    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.jpg',
                height: heroImageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 800,
                errorBuilder: (_, __, ___) => Container(
                  height: heroImageHeight,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Imagen no disponible')),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido a PoliSafe, tu sistema completo de enfermería profesional.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              return GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio(),
                ),
                itemCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final items = [
                    {
                      'title': 'PAES',
                      'subtitle': 'Planes de enfermería',
                      'image': 'assets/images/paes.jpeg',
                      'onTap': () => main?._goTo(2),
                    },
                    {
                      'title': 'Farmacología',
                      'subtitle': 'Medicamentos',
                      'image': 'assets/images/medicamentos.jpeg',
                      'onTap': () => main?._goTo(3),
                    },
                    {
                      'title': 'Cálculos',
                      'subtitle': 'Dosis clínicas',
                      'image': 'assets/images/calculadora.jpeg',
                      'onTap': () => main?._goTo(1),
                    },
                    {
                      'title': 'Quirúrgico',
                      'subtitle': 'Instrumental',
                      'image': 'assets/images/quirurgico.jpeg',
                      'onTap': () => main?._goTo(4),
                    },
                    {
                      'title': 'Estudio',
                      'subtitle': 'Material',
                      'image': 'assets/images/estudio.jpeg',
                      'onTap': () => main?._goTo(5),
                    },
                    {
                      'title': 'Ajustes',
                      'subtitle': 'Configuración',
                      'image': 'assets/images/ajustes.jpeg',
                      'onTap': () => main?._goTo(6),
                    },
                  ];

                  final item = items[index];
                  return ModernCard(
                    item['title'] as String,
                    item['subtitle'] as String,
                    item['image'] as String,
                    item['onTap'] as VoidCallback,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

/*════════════════════════ CARD ════════════════════════*/

class ModernCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback? onTap;

  const ModernCard(this.title, this.subtitle, this.image, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    // determine a sensible min height so cards don't collapse on very narrow columns
    final double minCardHeight =
        (MediaQuery.of(context).size.width / 4).clamp(120.0, 420.0);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minCardHeight),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      cacheWidth: 600,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 3, color: Colors.black54),
                          ],
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black45),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
