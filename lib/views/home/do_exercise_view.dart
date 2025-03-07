import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../view_models/do_exercise_view_model.dart';
import '../../widgets/timer_widget.dart';
import '../../widgets/value_counter.dart';

class DoExerciseView extends StatelessWidget {
  final Exercise exercise;

  const DoExerciseView({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(
      create: (_) => DoExerciseViewModel(exercise),
      child: Consumer<DoExerciseViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Выполнение упражнения", style: TextStyle(fontSize: 18)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Информация',
                  onPressed: () => _showExerciseInfo(context),
                ),
              ],
            ),
            body: viewModel.isCompleted
              ? _buildCompletedView(context)
              : _buildExerciseView(context, viewModel),
          );
        },
      ),
    );
  }

  void _showExerciseInfo(BuildContext context) {
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildExerciseTypeIcon(context),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 32,
                thickness: 2,
              ),
              _buildInfoItem(
                context, 
                Icons.fitness_center, 
                'Тип упражнения', 
                exercise.type.displayName,
              ),
              if (exercise.muscleGroup != null)
                _buildInfoItem(
                  context, 
                  Icons.accessibility_new, 
                  'Группа мышц', 
                  exercise.muscleGroup!,
                ),
              if (exercise.weight != null)
                _buildInfoItem(
                  context, 
                  Icons.fitness_center, 
                  'Вес', 
                  '${exercise.weight} кг',
                ),
              if (exercise.type == ExerciseType.time && exercise.time != null)
                _buildInfoItem(
                  context, 
                  Icons.timer, 
                  'Время', 
                  '${(exercise.time! / 60).ceil()} мин',
                ),
              if (exercise.type == ExerciseType.repetitions && exercise.sets != null)
                _buildSetsInfo(context),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Закрыть',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseTypeIcon(BuildContext context) {
    final iconData = exercise.type == ExerciseType.time
        ? Icons.timer
        : Icons.fitness_center;
    final theme = Theme.of(context);
    final color = exercise.type == ExerciseType.time
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 26,
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String value,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsInfo(BuildContext context) {
    if (exercise.sets == null || exercise.sets!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.repeat,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Подходы',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                const SizedBox(height: 6),
                ...exercise.sets!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Подход ${index + 1}: ${set.repetitions} повторений',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView(BuildContext context, DoExerciseViewModel viewModel) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide.none,
                ),
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        exercise.type == ExerciseType.time
                            ? Icons.timer
                            : Icons.fitness_center,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise.type == ExerciseType.time
                                  ? 'Упражнение на время'
                                  : 'Упражнение на повторения',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (exercise.type == ExerciseType.time)
                Expanded(
                  child: Center(
                    child: TimerWidget(
                      seconds: exercise.time ?? 60,
                      onTimeChanged: (time) => viewModel.currentTime = time,
                      onComplete: () => viewModel.completeExercise(),
                    ),
                  ),
                )
              else if (exercise.type == ExerciseType.repetitions)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: viewModel.actualSets.length,
                    itemBuilder: (context, index) {
                      final targetReps = exercise.sets?[index].repetitions ?? 0;
                      final targetWeight = exercise.sets?[index].weight ?? exercise.weight ?? 0;
                      final isCurrentSet = index == viewModel.currentSetIndex;
                      
                      return Opacity(
                        opacity: index < viewModel.currentSetIndex ? 0.6 : 1.0,
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withAlpha(26),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'Подход ${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (index < viewModel.currentSetIndex) Row(
                                      children: [
                                        Text(
                                          'Выполнено',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.brightness == Brightness.light 
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onPrimary,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isCurrentSet) ...[
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.flag,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Цель: $targetReps повторений${targetWeight > 0 ? ' по $targetWeight кг' : ''}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Выполнено повторений',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ValueCounter(
                                        label: 'Повторения',
                                        value: viewModel.getActualRepetitions(index),
                                        minValue: 0,
                                        maxValue: 999,
                                        onChanged: isCurrentSet && !viewModel.isResting
                                            ? (value) => viewModel.updateActualSet(index, repetitions: value)
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (viewModel.exercise.weight != null || viewModel.exercise.inventory != null || targetWeight > 0)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Вес (кг)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ValueCounter(
                                          label: 'Вес',
                                          value: viewModel.getActualWeight(index),
                                          minValue: 1,
                                          maxValue: 500,
                                          onChanged: isCurrentSet && !viewModel.isResting
                                              ? (value) => viewModel.updateActualSet(index, weight: value)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (isCurrentSet && !viewModel.isResting && index < viewModel.actualSets.length - 1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () => viewModel.startRestTimer(),
                                        child: Text(
                                          'Нажмите для отдыха ${exercise.restTime != null ? '(${exercise.restTime} сек)' : ''}',
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              if (exercise.type == ExerciseType.repetitions && !viewModel.isResting)
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16, top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide.none,
                      ),
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        title: const Text(
                          'Завершить упражнение',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () => viewModel.completeExercise(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          if (viewModel.isResting)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Отдых',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TimerWidget(
                            seconds: exercise.restTime ?? 60,
                            onTimeChanged: (time) => viewModel.updateRestTime(time),
                            onComplete: () {
                              viewModel.updateRestTime(0);
                              viewModel.skipRest();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => viewModel.skipRest(),
                            child: const Text(
                              'Пропустить отдых',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 90,
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Упражнение выполнено!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Отличная работа! Продолжайте в том же духе.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withAlpha(179),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Вернуться к тренировке',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 