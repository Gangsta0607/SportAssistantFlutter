import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  static ThemeManager get instance => _instance;
  
  // Процент примешивания акцентного цвета к фону
  static const double accentMixRatio = 0.05;
    
  // Доступные акцентные цвета
  static const List<Color> availableColors = [
    Color(0xFF2196F3),  // Голубой
    Color(0xFF9C27B0),  // Пурпурный
    Color(0xFF4CAF50),  // Зеленый
    Color(0xFFFF5722),  // Оранжево-красный
    Color(0xFF3F51B5),  // Индиго
    Color(0xFFE91E63),  // Розовый
    Color(0xFF009688),  // Бирюзовый
    Color(0xFFFFC107),  // Янтарный
    Color(0xFF673AB7),  // Темно-фиолетовый
    Color(0xFF00BCD4),  // Циан
    Color(0xFFF44336),  // Красный
    Color(0xFF8BC34A),  // Светло-зеленый
    Color(0xFF1976D2),  // Синий
    Color(0xFFA0A0FF),
  ];
  
  ThemeManager._internal();
  
  // Получение текущего акцентного цвета
  Future<Color> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('accentColor');
    return colorValue != null ? Color(colorValue) : Colors.blue;
  }
  
  // Получение текущего режима темы
  Future<int> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedColorScheme') ?? 0;
  }
  
  // Сохранение выбранного режима темы
  Future<void> setThemeMode(int themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColorScheme', themeMode);
  }
  
  // Создание улучшенной светлой темы
  ThemeData getLightTheme(Color accentColor) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        primary: accentColor,
        secondary: accentColor.withAlpha(204),
        tertiary: accentColor.withAlpha(153),
        surface: Color.lerp(Colors.white, accentColor, accentMixRatio)!,
        surfaceContainer: Color.lerp(const Color(0xFFF5F7FA), accentColor, accentMixRatio)!,
        error: const Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onTertiary: Colors.black87,
        onSurface: const Color(0xFF2D3748),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Color.lerp(const Color(0xFFF5F7FA), accentColor, accentMixRatio)!,
      cardTheme: CardTheme(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withAlpha(26)),
        ),
        color: Color.lerp(Colors.white, accentColor, accentMixRatio)!,
        shadowColor: Colors.black.withAlpha(13),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          foregroundColor: accentColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: accentColor,
        suffixIconColor: accentColor,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentColor.withAlpha(26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        selectedColor: accentColor.withAlpha(51),
        labelStyle: const TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: IconThemeData(
        color: accentColor,
        size: 24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withAlpha(51),
        thickness: 1,
        space: 24,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF2D3748),
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF2D3748),
        ),
        bodySmall: TextStyle(
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }
  
  ThemeData getDarkTheme(Color accentColor) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        primary: accentColor,
        secondary: accentColor.withAlpha(204),
        tertiary: accentColor.withAlpha(153),
        surface: Color.lerp(const Color(0xFF1A1A1A), accentColor, accentMixRatio)!,
        surfaceContainer: Color.lerp(const Color(0xFF121212), accentColor, accentMixRatio)!,
        surfaceContainerHighest: Color.lerp(const Color(0xFF2C2C2C), accentColor, accentMixRatio)!,
        error: const Color(0xFFFF5252),
        brightness: Brightness.dark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.black87,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white.withAlpha(230),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Color.lerp(const Color(0xFF121212), accentColor, accentMixRatio)!,
      cardTheme: CardTheme(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentColor.withAlpha(51), width: 1),
        ),
        color: Color.lerp(const Color(0xFF1A1A1A), accentColor, accentMixRatio)!,
        shadowColor: Colors.black.withAlpha(102),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          foregroundColor: accentColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: accentColor,
        suffixIconColor: accentColor,
        labelStyle: TextStyle(color: Colors.white.withAlpha(204)),
        hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentColor.withAlpha(51),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        selectedColor: accentColor.withAlpha(77),
        labelStyle: TextStyle(
          color: Colors.white.withAlpha(230),
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: IconThemeData(
        color: accentColor,
        size: 24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withAlpha(26),
        thickness: 1,
        space: 24,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: Colors.white.withAlpha(242),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.white.withAlpha(230),
        ),
        bodyMedium: TextStyle(
          color: Colors.white.withAlpha(230),
        ),
        bodySmall: TextStyle(
          color: Colors.white.withAlpha(179),
        ),
      ),
    );
  }
}

class ColorOption {
  final String name;
  final Color color;
  final String id;
  final bool isSelected;
  
  const ColorOption({
    required this.name,
    required this.color,
    required this.id,
    this.isSelected = false,
  });
  
  ColorOption copyWith({
    String? name,
    Color? color,
    String? id,
    bool? isSelected,
  }) {
    return ColorOption(
      name: name ?? this.name,
      color: color ?? this.color,
      id: id ?? this.id,
      isSelected: isSelected ?? this.isSelected,
    );
  }
} 