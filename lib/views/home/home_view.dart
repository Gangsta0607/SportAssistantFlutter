import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/exercise_widget.dart';
import 'do_exercise_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Главная'),
            ),
            body: RefreshIndicator(
              onRefresh: () => viewModel.loadSchedules(),
              child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSection(
                        context,
                        'Упражнения на сегодня',
                        viewModel.todaySchedule.exercises,
                        viewModel,
                        isToday: true,
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        'Упражнения на завтра',
                        viewModel.tomorrowSchedule.exercises,
                        viewModel,
                        isToday: false,
                      ),
                    ],
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Exercise> exercises,
    HomeViewModel viewModel, {
    bool isToday = true,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isToday ? Icons.today : Icons.calendar_month,
                color: isToday ? theme.colorScheme.primary : theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (exercises.isEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Нет запланированных упражнений',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте упражнения в расписание',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8)
                  ],
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
              final itemWidth = (constraints.maxWidth - (columnCount - 1) * 16) / columnCount;
              
              final exerciseWidgets = exercises.map((exercise) {
                return Container(
                  width: itemWidth,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FutureBuilder<DateTime?>(
                    future: viewModel.getLastExecutedDate(exercise.id),
                    builder: (context, snapshot) {
                      final isCompleted = snapshot.hasData && 
                                         viewModel.sameDate(snapshot.data);
                      
                      final hasProgress = snapshot.hasData;
                      
                      return ExerciseWidget(
                        exercise: exercise,
                        isCompleted: isCompleted,
                        showHistoryButton: isToday && hasProgress,
                        onTap: isToday && !isCompleted
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DoExerciseView(exercise: exercise),
                                  ),
                                ).then((_) => viewModel.loadSchedules())
                            : null,
                      );
                    },
                  ),
                );
              }).toList();

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: exerciseWidgets,
              );
            },
          ),
      ],
    );
  }
} 