import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'views/home/home_view.dart';
import 'views/schedule/schedule_view.dart';
import 'views/settings/settings_view.dart';
import 'utilities/theme_manager.dart';
import 'view_models/settings_view_model.dart';
import 'utilities/data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeMode = prefs.getInt('selectedColorScheme') ?? 0;
  
  final settingsViewModel = SettingsViewModel(DataManager.instance);
  await settingsViewModel.initialize();
  
  runApp(
    ChangeNotifierProvider<SettingsViewModel>.value(
      value: settingsViewModel,
      child: MyApp(
        initialThemeMode: themeMode,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final int initialThemeMode;
  
  const MyApp({
    Key? key, 
    required this.initialThemeMode,
  }) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late int _themeMode;
  late ThemeManager _themeManager;
  Timer? _timer;
  bool _isThemeLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _themeManager = ThemeManager.instance;
    _loadTheme();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkThemeChanges();
    });
  }
  
  Future<void> _loadTheme() async {
    setState(() {
      _isThemeLoaded = true;
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _checkThemeChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode = prefs.getInt('selectedColorScheme') ?? 0;
    
    if (newThemeMode != _themeMode) {
      setState(() {
        _themeMode = newThemeMode;
      });
    }
  }
  
  ThemeMode _getThemeMode() {
    switch (_themeMode) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThemeLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final viewModel = context.watch<SettingsViewModel>();
    
    return MaterialApp(
      title: 'Sport Assistant',
      theme: _themeManager.getLightTheme(viewModel.accentColor),
      darkTheme: _themeManager.getDarkTheme(viewModel.accentColor),
      themeMode: _getThemeMode(),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const ScheduleView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary.withAlpha(51),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
} 