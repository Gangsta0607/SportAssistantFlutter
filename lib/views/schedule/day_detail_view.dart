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
  static const double _defaultBorderRadius = 30.0;
  static const Duration _animationDuration = Duration(milliseconds: 200);
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

  void _removeExercise(int index) {
    _updateExercises((exercises) {
      exercises.removeAt(index);
      return exercises;
    });
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
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: theme.colorScheme.error,
          ),
          tooltip: 'Удалить',
          onPressed: () => _removeExercise(index),
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
          IconButton(
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
      floatingActionButton: _isEditMode ? AnimatedContainer(
        duration: _animationDuration,
        child: FloatingActionButton(
          onPressed: _navigateToAddExercise,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add),
        ),
      ) : null,
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
            const Text(
              'Нажмите на кнопку ниже, чтобы добавить упражнение',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _defaultSpacing * 2),
            AnimatedContainer(
              duration: _animationDuration,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_defaultBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                label: const Text("Добавить упражнение"),
                onPressed: _navigateToAddExercise,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(_defaultPadding),
      itemCount: _currentDay.exercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: _defaultSpacing),
      itemBuilder: (context, index) {
        final exercise = _currentDay.exercises[index];
        final theme = Theme.of(context);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _exerciseMaxWidth),
            child: ExerciseWidget(
              exercise: exercise,
              showHistoryButton: !_isEditMode,
              editButtons: _isEditMode ? _buildEditButtons(exercise, index, theme) : null,
            ),
          ),
        );
      },
    );
  }
} 