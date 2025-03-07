import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../view_models/exercise_history_view_model.dart';
import 'package:intl/intl.dart';

class ExerciseHistoryView extends StatelessWidget {
  final Exercise exercise;

  const ExerciseHistoryView({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExerciseHistoryViewModel(exercise),
      child: Consumer<ExerciseHistoryViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Прогресс'),
              actions: [
                if (viewModel.historyResults != null && viewModel.historyResults!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Очистить историю',
                    onPressed: () => _showClearHistoryDialog(context, viewModel),
                  ),
              ],
            ),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ExerciseHistoryViewModel viewModel) {
    final theme = Theme.of(context);
    
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.historyResults == null || viewModel.historyResults!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_outlined,
                size: 80,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'Нет данных о выполнении упражнения',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Выполните упражнение, чтобы увидеть историю тренировок',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(179), // 0.7 * 255
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Название упражнения
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.primaryContainer.withAlpha(179), // 0.7 * 255
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildExerciseTypeIcon(theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                if (exercise.muscleGroup != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Группа мышц: ${exercise.muscleGroup}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimaryContainer.withAlpha(204), // 0.8 * 255
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // График прогресса
        if (viewModel.historyResults!.length > 1)
          _buildProgressChart(context, viewModel),
        
        const SizedBox(height: 16),
        
        // Заголовок списка тренировок
        Row(
          children: [
            Icon(
              Icons.history,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'История тренировок',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Список тренировок
        ...viewModel.historyResults!.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final reversedIndex = viewModel.historyResults!.length - 1 - index;
          final date = DateTime.now().subtract(Duration(days: reversedIndex));
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withAlpha(51), // 0.2 * 255
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(26), // 0.1 * 255
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Тренировка ${reversedIndex + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildResultBadge(context, result),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseTypeIcon(ThemeData theme) {
    final iconData = exercise.type == ExerciseType.time
        ? Icons.timer
        : Icons.fitness_center;
    
    final color = exercise.type == ExerciseType.time
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(51), // 0.2 * 255
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildResultBadge(BuildContext context, int result) {
    final theme = Theme.of(context);
    final iconData = exercise.type == ExerciseType.time
        ? Icons.timer
        : Icons.fitness_center;
    final resultText = exercise.type == ExerciseType.time
        ? _formatTime(result)
        : result.toString();
    final unitText = exercise.type == ExerciseType.time
        ? ''
        : ' повт.';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(26), // 0.1 * 255
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            resultText + unitText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(BuildContext context, ExerciseHistoryViewModel viewModel) {
    final theme = Theme.of(context);
    final results = viewModel.historyResults!;
    
    // Ограничиваем количество отображаемых результатов до 7, если их больше
    final displayResults = results.length > 7 
        ? results.sublist(results.length - 7) 
        : results;
    
    final maxValue = displayResults.reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Прогресс',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // График
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: displayResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final percentage = maxValue > 0 ? value / maxValue : 0.0;
                  final barHeight = 80 * percentage;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Значение
                          Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          
                          // Столбец
                          Container(
                            height: barHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          
                          // Индекс
                          const SizedBox(height: 2),
                          Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontSize: 8,
                              color: theme.colorScheme.onSurface.withAlpha(179), // 0.7 * 255
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Подпись
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  exercise.type == ExerciseType.time ? 'Время (сек)' : 'Повторения',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  void _showClearHistoryDialog(BuildContext context, ExerciseHistoryViewModel viewModel) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю'),
        content: const Text(
          'Вы уверены, что хотите удалить всю историю выполнения этого упражнения?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
} 