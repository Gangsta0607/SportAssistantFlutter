import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../view_models/add_exercise_view_model.dart';
import '../../widgets/value_counter.dart';

class AddExerciseView extends StatelessWidget {
  final Function(Exercise) onSave;
  final Exercise? initialExercise;

  const AddExerciseView({
    Key? key,
    required this.onSave,
    this.initialExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddExerciseViewModel(initialExercise: initialExercise),
      child: Consumer<AddExerciseViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                viewModel.isEditing ? 'Редактировать упражнение' : 'Добавить упражнение',
                style: const TextStyle(fontSize: 17),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (viewModel.validateAndShowErrors()) {
                      onSave(viewModel.createExercise());
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            body: _ExerciseForm(viewModel: viewModel),
          );
        },
      ),
    );
  }
}

class _ExerciseForm extends StatefulWidget {
  final AddExerciseViewModel viewModel;

  const _ExerciseForm({Key? key, required this.viewModel}) : super(key: key);

  @override
  _ExerciseFormState createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  late final TextEditingController titleController;
  late final TextEditingController muscleGroupController;
  late final TextEditingController inventoryController;
  late TextEditingController weightController;
  late TextEditingController restTimeController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.viewModel.title);
    muscleGroupController = TextEditingController(text: widget.viewModel.muscleGroup ?? '');
    inventoryController = TextEditingController(text: widget.viewModel.inventory ?? '');
    weightController = TextEditingController(text: widget.viewModel.weight?.toString() ?? '');
    restTimeController = TextEditingController(text: widget.viewModel.restTime?.toString() ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    muscleGroupController.dispose();
    inventoryController.dispose();
    weightController.dispose();
    restTimeController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration({
    required String hintText,
    bool showError = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: showError 
            ? theme.colorScheme.error 
            : theme.colorScheme.outline.withAlpha(77),
          width: showError ? 2.0 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: showError 
            ? theme.colorScheme.error 
            : theme.colorScheme.primary,
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 14,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название упражнения
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Название упражнения'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _getInputDecoration(
                  hintText: 'Введите название упражнения',
                  showError: viewModel.showTitleError,
                ),
                controller: titleController,
                onChanged: (value) => viewModel.title = value,
              ),
              if (viewModel.showTitleError)
                _buildErrorMessage('Необходимо указать название упражнения'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Группа мышц
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Группа мышц'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _getInputDecoration(
                  hintText: 'Например: грудь, спина, ноги',
                ),
                controller: muscleGroupController,
                onChanged: (value) => viewModel.muscleGroup = value,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Тип упражнения
          
          // Время отдыха (только для не временных упражнений)
          if (viewModel.type != ExerciseType.time) ...[
            ValueCounter(
              label: 'Время отдыха (сек)',
              value: viewModel.restTime ?? 120,
              minValue: 0,
              maxValue: 300,
              onChanged: (value) => viewModel.restTime = value,
            ),
            const SizedBox(height: 24),
          ],
          
          // Переключатель инвентаря
          Row(
            children: [
              _buildSectionTitle('Инвентарь'),
              const Spacer(),
              Switch(
                value: viewModel.hasInventory,
                onChanged: (value) => viewModel.hasInventory = value,
              ),
            ],
          ),
          
          // Поля инвентаря
          if (viewModel.hasInventory) ...[
            const SizedBox(height: 16),
            TextFormField(
              decoration: _getInputDecoration(
                hintText: 'Укажите необходимый инвентарь',
              ),
              controller: inventoryController,
              onChanged: (value) => viewModel.inventory = value,
            ),
            if (viewModel.type != ExerciseType.time) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSectionTitle('Разные веса для подходов'),
                  const Spacer(),
                  Switch(
                    value: viewModel.hasDifferentWeights,
                    onChanged: (value) => viewModel.hasDifferentWeights = value,
                  ),
                ],
              ),
            ],
            if (!viewModel.hasDifferentWeights) ...[
              const SizedBox(height: 16),
              ValueCounter(
                label: 'Вес (кг)',
                value: viewModel.weight ?? 10,
                minValue: 1,
                maxValue: 500,
                onChanged: (value) => viewModel.weight = value,
              ),
            ],
          ],
          const SizedBox(height: 24),
          _buildSectionTitle('Тип упражнения'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildExerciseTypeButton(
                  context: context,
                  title: 'Время',
                  icon: Icons.timer,
                  isSelected: viewModel.type == ExerciseType.time,
                  onTap: () => viewModel.type = ExerciseType.time,
                ),
                const SizedBox(width: 16),
                _buildExerciseTypeButton(
                  context: context,
                  title: 'Повторения',
                  icon: Icons.fitness_center,
                  isSelected: viewModel.type == ExerciseType.repetitions,
                  onTap: () => viewModel.type = ExerciseType.repetitions,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Секция подходов для временных упражнений
          if (viewModel.type == ExerciseType.time)
            _buildTimeSection(viewModel)
          else
            _buildRepetitionsSection(viewModel),
        ],
      ),
    );
  }

  Widget _buildTimeSection(AddExerciseViewModel viewModel) {
    final timeInSeconds = viewModel.time ?? 60;
    final timeInMinutes = (timeInSeconds / 60).ceil();
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Настройка времени упражнения',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueCounter(
                      label: 'Продолжительность (в минутах)',
                      value: timeInMinutes,
                      minValue: 1,
                      maxValue: 300,
                      onChanged: (value) => viewModel.time = value * 60,
                    ),
                    const SizedBox(height: 16),
                    // Быстрые пресеты времени
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimePresetButton(1, timeInMinutes, viewModel, theme),
                        _buildTimePresetButton(5, timeInMinutes, viewModel, theme),
                        _buildTimePresetButton(10, timeInMinutes, viewModel, theme),
                        _buildTimePresetButton(15, timeInMinutes, viewModel, theme),
                        _buildTimePresetButton(30, timeInMinutes, viewModel, theme),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Информационный блок
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Общее время: $timeInMinutes мин (${timeInMinutes * 60} сек)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
                      if (viewModel.showTimeError)
          _buildErrorMessage('Необходимо указать время упражнения'),
            ],
    );
  }

  Widget _buildTimePresetButton(int minutes, int currentValue, AddExerciseViewModel viewModel, ThemeData theme) {
    final isSelected = currentValue == minutes;
    
    return InkWell(
      onTap: () {
        viewModel.time = minutes * 60;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$minutes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildRepetitionsSection(AddExerciseViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Разные подходы'),
            const Spacer(),
            Switch(
              value: viewModel.setType == SetType.different,
              onChanged: (value) {
                viewModel.setType = value ? SetType.different : SetType.same;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (viewModel.setType == SetType.same)
          _buildSameSetsSection(viewModel)
        else
          _buildDifferentSetsSection(viewModel),
          
        if (viewModel.showSetsError)
          _buildErrorMessage('Необходимо добавить хотя бы один подход'),
      ],
    );
  }

  Widget _buildSameSetsSection(AddExerciseViewModel viewModel) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Настройка подходов',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueCounter(
                label: 'Количество подходов',
                value: viewModel.numberOfSets,
                minValue: 1,
                maxValue: 10,
                onChanged: (value) {
                  viewModel.numberOfSets = value;
                  viewModel.generateSameSets();
                },
              ),
              const SizedBox(height: 16),
              ValueCounter(
                label: 'Повторений в подходе',
                value: viewModel.repetitionsPerSet,
                minValue: 1,
                maxValue: 50,
                onChanged: (value) {
                  viewModel.repetitionsPerSet = value;
                  viewModel.generateSameSets();
                },
              ),
            ],
          ),
        ),
        
        if (viewModel.hasInventory && viewModel.hasDifferentWeights) ...[
          const SizedBox(height: 24),
          Text(
            'Веса для каждого подхода',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.sets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final set = viewModel.sets[index];
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Подход ${index + 1}: ${viewModel.repetitionsPerSet} повторений',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueCounter(
                      subtitle: 'Вес (кг)',
                      value: set.weight ?? 10,
                      minValue: 1,
                      maxValue: 500,
                      onChanged: (value) => viewModel.updateSetWeight(index, value),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDifferentSetsSection(AddExerciseViewModel viewModel) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Настройка подходов',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => viewModel.addSet(10),
              child: const Text('Добавить подход'),
            ),
          ],
        ),
        if (viewModel.sets.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: theme.colorScheme.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Нет добавленных подходов',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите "Добавить подход" для создания нового подхода',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.sets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final set = viewModel.sets[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Подход ${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => viewModel.removeSet(index),
                          color: theme.colorScheme.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueCounter(
                      subtitle: 'Повторения',
                      value: set.repetitions,
                      minValue: 1,
                      maxValue: 50,
                      onChanged: (value) => viewModel.updateSet(index, value),
                    ),
                    if (viewModel.hasInventory && viewModel.hasDifferentWeights) ...[
                      const SizedBox(height: 16),
                      ValueCounter(
                        subtitle: 'Вес (кг)',
                        value: set.weight ?? 10,
                        minValue: 1,
                        maxValue: 500,
                        onChanged: (value) => viewModel.updateSetWeight(index, value),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildExerciseTypeButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size.width * 0.4;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(77),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
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
}



