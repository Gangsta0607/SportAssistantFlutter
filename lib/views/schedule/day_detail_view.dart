import 'package:flutter/material.dart';
import '../../models/day.dart';
import '../../models/exercise.dart';
import '../../widgets/exercise_widget.dart';
import 'add_exercise_view.dart';

class DayDetailView extends StatefulWidget {
  final Day day;
  final Function(Day) onSave;

  const DayDetailView({
    Key? key,
    required this.day,
    required this.onSave,
  }) : super(key: key);

  @override
  DayDetailViewState createState() => DayDetailViewState();
}

class DayDetailViewState extends State<DayDetailView> {
  static const double _defaultPadding = 16.0;
  static const double _defaultSpacing = 16.0;
  static const double _defaultIconSize = 24.0;
  static const double _defaultEmptyStateIconSize = 64.0;
  static const double _exerciseMaxWidth = 400.0;

  late Day _currentDay;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.day;
  }

  void _updateExercises(List<Exercise> Function(List<Exercise>) update) {
    setState(() {
      final updatedExercises = update(List<Exercise>.from(_currentDay.exercises));
      _currentDay = _currentDay.copyWith(exercises: updatedExercises);
    });
    widget.onSave(_currentDay);
  }

  void _addExercise(Exercise exercise) {
    _updateExercises((exercises) => exercises..add(exercise));
  }


  void _editExercise(int index, Exercise updatedExercise) {
    _updateExercises((exercises) {
      exercises[index] = updatedExercise;
      return exercises;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _navigateToAddExercise([Exercise? initialExercise, void Function(Exercise)? onSaveCallback]) async {
    await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseView(
          initialExercise: initialExercise,
          onSave: (exercise) {
            if (onSaveCallback != null) {
              onSaveCallback(exercise);
            } else {
              _addExercise(exercise);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEditButtons(Exercise exercise, int index, ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: theme.colorScheme.primary,
            size: _defaultIconSize,
          ),
          tooltip: 'Редактировать',
          onPressed: () => _navigateToAddExercise(exercise, (updatedExercise) {
            _editExercise(index, updatedExercise);
          }),
        ),
        PopupMenuButton<String>(
          tooltip: 'Удалить',
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: theme.colorScheme.error,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          position: PopupMenuPosition.under,
          color: theme.colorScheme.surface,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Подтвердить удаление',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              // Добавляем небольшую анимацию перед удалением
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Упражнение "${exercise.title}" удалено'),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(8),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Отменить',
                    onPressed: () {
                      // Восстанавливаем упражнение, если пользователь нажал "Отменить"
                      _updateExercises((exercises) {
                        exercises.insert(index, exercise);
                        return exercises;
                      });
                    },
                  ),
                ),
              );
              _updateExercises((exercises) {
                exercises.removeAt(index);
                return exercises;
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentDay.name),
        actions: [
          if (_currentDay.exercises.isNotEmpty) IconButton(
            icon: Icon(
              _isEditMode ? Icons.check : Icons.edit,
            ),
            tooltip: _isEditMode ? 'Готово' : 'Редактировать',
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentDay.exercises.isEmpty
              ? _buildEmptyState(theme)
              : _buildExercisesList(),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(_defaultPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: _defaultEmptyStateIconSize,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: _defaultSpacing + 8),
            const Text(
              'Нет упражнений на этот день',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _defaultSpacing),
            TextButton.icon(
                label: const Text("Добавить упражнение", style: TextStyle(fontSize: 16),),
                onPressed: _navigateToAddExercise,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    final theme = Theme.of(context);
    // Создаем список виджетов для отображения
    final List<Widget> listItems = [];
    // Добавляем все упражнения
    for (int index = 0; index < _currentDay.exercises.length; index++) {
      final exercise = _currentDay.exercises[index];
      listItems.add(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _exerciseMaxWidth),
            child: ExerciseWidget(
              key: ValueKey('exercise_${exercise.id}'),
              exercise: exercise,
              showHistoryButton: !_isEditMode,
              editButtons: _isEditMode ? _buildEditButtons(exercise, index, theme) : null,
            ),
          ),
        ),
      );
    }
    // Если в режиме редактирования, добавляем кнопку "Добавить упражнение" в конец списка
    if (_isEditMode) {
      listItems.add(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _exerciseMaxWidth),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _navigateToAddExercise,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Добавить упражнение',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    // Возвращаем ListView с разделителями
    return ListView.separated(
      padding: const EdgeInsets.all(_defaultPadding),
      itemCount: listItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: _defaultSpacing),
      itemBuilder: (context, index) => listItems[index],
    );
  }
} 