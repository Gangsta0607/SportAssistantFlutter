import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../view_models/settings_view_model.dart';
import '../../utilities/theme_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _showServerControls = false;

  Widget customButton(String text, func, Icon icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: icon,
        onTap: func,
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    {
      required IconData icon,
      required String label,
      required int value,
      required SettingsViewModel viewModel,
    }
  ) {
    final isSelected = viewModel.selectedColorScheme == value;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => viewModel.updateColorScheme(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withAlpha(26)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(128),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Настройки'),
            actions: [
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    _showServerControls = !_showServerControls;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_showServerControls 
                        ? 'Управление сервером включено' 
                        : 'Управление сервером отключено'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const SizedBox(
                  width: 48,
                  child: Icon(Icons.more_vert,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(13),
                      blurRadius: 8,
                      spreadRadius: -2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.color_lens,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Тема оформления',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 180,
                                child: _buildThemeOption(
                                  context,
                                  icon: Icons.brightness_auto,
                                  label: 'Авто',
                                  value: 0,
                                  viewModel: viewModel,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 180,
                                child: _buildThemeOption(
                                  context,
                                  icon: Icons.light_mode,
                                  label: 'Светлая',
                                  value: 1,
                                  viewModel: viewModel,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 180,
                                child: _buildThemeOption(
                                  context,
                                  icon: Icons.dark_mode,
                                  label: 'Тёмная',
                                  value: 2,
                                  viewModel: viewModel,
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                icon: Icons.brightness_auto,
                                label: 'Авто',
                                value: 0,
                                viewModel: viewModel,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                icon: Icons.light_mode,
                                label: 'Светлая',
                                value: 1,
                                viewModel: viewModel,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                icon: Icons.dark_mode,
                                label: 'Тёмная',
                                value: 2,
                                viewModel: viewModel,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Акцентный цвет',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...ThemeManager.availableColors.map((color) {
                          final isSelected = viewModel.accentColor == color;
                          return GestureDetector(
                            onTap: () => viewModel.updateAccentColor(color),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.white.withAlpha(204),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  BoxShadow(
                                    color: color.withAlpha(77),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                Color pickerColor = viewModel.accentColor;
                                return AlertDialog(
                                  title: const Text(
                                    'Выберите цвет',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: (Color color) {
                                        pickerColor = color;
                                      },
                                      pickerAreaHeightPercent: 0.8,
                                      enableAlpha: false,
                                      labelTypes: const [],
                                      displayThumbColor: true,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Отмена'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        viewModel.updateAccentColor(pickerColor);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Выбрать',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withAlpha(77),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.colorize,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_showServerControls) ...[
                const SizedBox(height: 24),
                const Text(
                  'Управление данными',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columnCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                    final itemWidth = (constraints.maxWidth - (columnCount - 1) * 16) / columnCount;
                    
                    final serverControls = [
                      SizedBox(
                        width: itemWidth,
                        child: TextField(
                          controller: viewModel.serverAddressController,
                          decoration: InputDecoration(
                            hintText: 'Например: 192.168.1.100',
                            labelText: 'Адрес сервера',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: customButton(
                          'Отправить данные на сервер',
                          () async {
                            await viewModel.syncToServer(context);
                          },
                          const Icon(Icons.upload),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: customButton(
                          'Получить данные с сервера',
                          () async {
                            await viewModel.syncFromServer(context);
                          },
                          const Icon(Icons.download),
                        ),
                      ),
                    ];

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: serverControls,
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columnCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                  final itemWidth = (constraints.maxWidth - (columnCount - 1) * 16) / columnCount;
                  
                  final dangerButtons = [
                    SizedBox(
                      width: itemWidth,
                      child: customButton(
                        'Очистить данные о прогрессе',
                        () {
                          viewModel.clearAllProgress();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Данные о прогрессе очищены'),
                            ),
                          );
                        },
                        const Icon(Icons.delete)
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: customButton(
                        'Очистить все данные',
                        () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Подтверждение',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Вы уверены, что хотите очистить все данные? Это действие нельзя отменить.',
                                style: TextStyle(fontSize: 16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Отмена'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    viewModel.clearAllData();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Все данные очищены'),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Очистить',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        const Icon(Icons.delete_forever)
                      ),
                    ),
                  ];

                  return Wrap(
                    spacing: 16,
                    children: dangerButtons,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 