import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../views/home/exercise_history_view.dart';

class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback? onTap;
  final bool showHistoryButton;
  final Widget? editButtons;

  const ExerciseWidget({
    Key? key,
    required this.exercise,
    this.isCompleted = false,
    this.onTap,
    this.showHistoryButton = true,
    this.editButtons,
  }) : super(key: key);

  // Функция для склонения слова "повторение" в зависимости от числа
  String _getRepetitionsWord(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    
    if (mod10 == 1 && mod100 != 11) {
      return 'повторение';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'повторения';
    } else {
      return 'повторений';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final isDarkTheme = !isLightTheme;
    
    return Card(
      elevation: isLightTheme ? 1 : 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDarkTheme ? [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(13),
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildExerciseTypeIcon(context, isLightTheme),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercise.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (editButtons != null)
                        editButtons!,
                      if (!isCompleted && showHistoryButton && editButtons == null)
                        IconButton(
                          icon: Icon(
                            Icons.history,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          tooltip: 'История упражнения',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseHistoryView(exercise: exercise),
                              ),
                            );
                          },
                        ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLightTheme
                                  ? theme.colorScheme.primary.withAlpha(38)
                                  : theme.colorScheme.primary.withAlpha(64),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: isLightTheme 
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Выполнено',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isLightTheme 
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onPrimary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildExerciseDetails(context, isLightTheme),
              if (!isCompleted && !showHistoryButton && editButtons == null && onTap != null) GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: isLightTheme
                                    ? theme.colorScheme.primary.withAlpha(38)
                                    : theme.colorScheme.primary.withAlpha(64),
                                borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Row(
                    children: [
                      Text("Выполнить упражнение",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        )
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward
                      )
                    ]
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTypeIcon(BuildContext context, bool isLightTheme) {
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
        color: color.withAlpha(isLightTheme ? 31 : 51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildExerciseDetails(BuildContext context, bool isLightTheme) {
    final theme = Theme.of(context);
    final List<Widget> detailWidgets = [];

    if (exercise.type == ExerciseType.time && exercise.time != null) {
      detailWidgets.add(
        _buildDetailRow(
          context,
          Icons.timer,
          'Время: ${(exercise.time! / 60).ceil()} мин',
          isLightTheme: isLightTheme,
        ),
      );
    }
    
    if (exercise.type == ExerciseType.repetitions && exercise.sets != null) {
      detailWidgets.add(_buildSetsInfo(context, isLightTheme));
    }

    if (exercise.muscleGroup != null) {
      detailWidgets.add(
        _buildDetailRow(
          context,
          Icons.fitness_center,
          'Группа мышц: ${exercise.muscleGroup}',
          addBottomPadding: true,
          isLightTheme: isLightTheme,
        ),
      );
    }

    if (exercise.restTime != null) {
      String restTimeText = 'Время отдыха: ${exercise.restTime} с.';
      
      detailWidgets.add(
        _buildDetailRow(
          context,
          Icons.timer,
          restTimeText,
          addBottomPadding: true,
          isLightTheme: isLightTheme,
        ),
      );
    }

    if (exercise.inventory != null && exercise.inventory!.isNotEmpty) {
      String inventoryText = 'Инвентарь: ${exercise.inventory}';
      if (exercise.weight != null) {
        inventoryText += ', ${exercise.weight} кг';
      }
      
      detailWidgets.add(
        _buildDetailRow(
          context,
          Icons.sports_gymnastics,
          inventoryText,
          addBottomPadding: false,
          isLightTheme: isLightTheme,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLightTheme 
            ? theme.colorScheme.surfaceContainerHighest.withAlpha(77)
            : theme.colorScheme.surfaceContainerHighest.withAlpha(127),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: detailWidgets,
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, 
    IconData icon, 
    String text, 
    {bool addBottomPadding = true, required bool isLightTheme}
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        left: 6,
        right: 6,
        top: 6,
        bottom: addBottomPadding ? 6 : 0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isLightTheme
                  ? theme.colorScheme.primary.withAlpha(26)
                  : theme.colorScheme.primary.withAlpha(64),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: isLightTheme 
                  ? theme.colorScheme.primary
                  : Colors.white.withAlpha(230),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withAlpha(204),
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsInfo(BuildContext context, bool isLightTheme) {
    final theme = Theme.of(context);
    
    if (exercise.sets == null || exercise.sets!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (exercise.hasIdenticalSets) {
      // Для одинаковых подходов
      final reps = exercise.sets!.first.repetitions;
      final sets = exercise.sets!.length;
      return _buildDetailRow(
        context,
        Icons.repeat,
        'Подходы: $sets x $reps ${_getRepetitionsWord(reps)}',
        isLightTheme: isLightTheme,
      );
    } else {
      // Для разных подходов
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            context,
            Icons.repeat,
            'Подходы:',
            isLightTheme: isLightTheme,
            addBottomPadding: false,
          ),
          ...exercise.sets!.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Text(
                '${index + 1}) ${set.repetitions} ${_getRepetitionsWord(set.repetitions)}${set.weight != null ? ' - ${set.weight} кг' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(204),
                ),
              ),
            );
          }).toList(),
        ],
      );
    }
  }
} 