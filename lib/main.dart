import 'package:flutter/material.dart';
import 'features/blood_donation/controllers/blood_donation_controller.dart';
import 'features/blood_donation/view/add_donation_view.dart';
import 'features/blood_donation/view/chart_view.dart';

void main() {
  runApp(const BloodDonationApp());
}

class BloodDonationApp extends StatefulWidget {
  const BloodDonationApp({super.key});

  @override
  State<BloodDonationApp> createState() => _BloodDonationAppState();
}

class _BloodDonationAppState extends State<BloodDonationApp> {
  final BloodDonationController _controller = BloodDonationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _controller.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Kan Bağış Grafiği',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF1744), // Vibrant Electric Crimson
              primary: const Color(0xFFFF1744),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F8FC),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF2A6D), // Vibrant Neon Rose
              primary: const Color(0xFFFF2A6D),
              surface: const Color(0xFF161922),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F1117), // Deep Obsidian
            cardTheme: CardThemeData(
              color: const Color(0xFF161922),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Color(0xFF161922),
            ),
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Color(0xFF161922),
              indicatorColor: Color(0x33FF2A6D),
            ),
          ),
          home: HomeShell(controller: _controller),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final BloodDonationController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AddDonationView(controller: widget.controller),
      ChartView(controller: widget.controller),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Bağış Ekle',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Grafik',
          ),
        ],
      ),
    );
  }
}
