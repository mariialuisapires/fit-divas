import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/water_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/weight_provider.dart';
import 'providers/calendar_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'screens/water/water_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/evolution/evolution_screen.dart';
import 'screens/challenges/challenges_screen.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const FitDivasApp());
}

class FitDivasApp extends StatelessWidget {
  const FitDivasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: MaterialApp(
        title: 'FitDivas',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool _isChecking = true;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().checkAuth();
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Color(0xFFE91E8C)),
              SizedBox(height: 16),
              Text('FitDivas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C))),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (!auth.isLoggedIn) {
      if (_showRegister) {
        return RegisterScreen(
          onRegisterSuccess: () => setState(() => _showRegister = false),
          onGoLogin: () => setState(() => _showRegister = false),
        );
      }
      return LoginScreen(
        onLoginSuccess: () => setState(() {}),
        onGoRegister: () => setState(() => _showRegister = true),
      );
    }

    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    WorkoutsScreen(),
    ChallengesScreen(),
    WaterScreen(),
    CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Desafios',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Água',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
        ],
      ),
      floatingActionButton: _MoreMenu(
        onEvolution: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvolutionScreen())),
        onAi: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
        onProfile: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      ),
    );
  }
}

class _MoreMenu extends StatefulWidget {
  final VoidCallback onEvolution;
  final VoidCallback onAi;
  final VoidCallback onProfile;

  const _MoreMenu({required this.onEvolution, required this.onAi, required this.onProfile});

  @override
  State<_MoreMenu> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<_MoreMenu> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _action(VoidCallback fn) {
    _toggle();
    fn();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _SpeedDialItem(icon: Icons.monitor_weight, label: 'Evolução', onTap: () => _action(widget.onEvolution)),
          const SizedBox(height: 8),
          _SpeedDialItem(icon: Icons.smart_toy, label: 'Assistente IA', onTap: () => _action(widget.onAi)),
          const SizedBox(height: 8),
          _SpeedDialItem(icon: Icons.person, label: 'Perfil', onTap: () => _action(widget.onProfile)),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _SpeedDialItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SpeedDialItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4)],
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }
}
