import 'package:flutter/material.dart';
import '../utilities/data_manager.dart';
import '../utilities/server_sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  final DataManager _dataManager;
  int _selectedColorScheme = 0;
  Color _accentColor = Colors.blue;
  late TextEditingController serverAddressController;
  Offset? _lastTapPosition;
  bool _initialized = false;

  SettingsViewModel(this._dataManager) {
    serverAddressController = TextEditingController(text: ServerSyncManager.serverAddress);
    serverAddressController.addListener(_onServerAddressChanged);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadThemeMode();
    await _loadAccentColor();
    _initialized = true;
  }

  @override
  void dispose() {
    serverAddressController.removeListener(_onServerAddressChanged);
    serverAddressController.dispose();
    super.dispose();
  }

  void _onServerAddressChanged() {
    ServerSyncManager.serverAddress = serverAddressController.text;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedColorScheme = prefs.getInt('selectedColorScheme') ?? 0;
    notifyListeners();
  }

  Future<void> _loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('accentColor');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
      notifyListeners();
    }
  }

  int get selectedColorScheme => _selectedColorScheme;
  Offset? get lastTapPosition => _lastTapPosition;
  Color get accentColor => _accentColor;

  void setLastTapPosition(Offset position) {
    _lastTapPosition = position;
    notifyListeners();
  }

  Future<void> updateColorScheme(int value) async {
    if (value == _selectedColorScheme) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColorScheme', value);
    _selectedColorScheme = value;
    notifyListeners();
  }

  Future<void> updateAccentColor(Color color) async {
    if (color == _accentColor) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.toARGB32());
    _accentColor = color;
    notifyListeners();
  }

  Future<bool> syncToServer(BuildContext context) async {
    return await _dataManager.syncToServer(context);
  }

  Future<bool> syncFromServer(BuildContext context) async {
    return await _dataManager.syncFromServer(context);
  }

  Future<void> clearAllProgress() async {
    await _dataManager.clearAllProgress();
  }

  Future<void> clearAllData() async {
    await _dataManager.clearEverything();
  }
} 