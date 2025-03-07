import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_models/schedule_view_model.dart';
import 'day_detail_view.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenScheduleInfo = prefs.getBool('has_seen_schedule_info') ?? false;
    
    if (mounted) {
      setState(() {
        _showInfo = !hasSeenScheduleInfo;
      });
    }
  }

  Future<void> _hideInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_schedule_info', true);
    
    if (mounted) {
      setState(() {
        _showInfo = false;
      });
    }
  }

  String _getExercisesWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'упражнение';
    } else if ((count % 10 >= 2 && count % 10 <= 4) && 
              !(count % 100 >= 12 && count % 100 <= 14)) {
      return 'упражнения';
    } else {
      return 'упражнений';
    }
  }

  Widget _buildInfoCard(BuildContext context, double width) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                            'Здесь вы можете настроить тренировки на каждый день недели. Нажмите на любой день, чтобы добавить или изменить упражнения.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      const SizedBox(width: 24),
                    ],
                  ),                  
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _hideInfo,
                tooltip: 'Закрыть',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleViewModel(),
      child: Consumer<ScheduleViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Расписание'),
            ),
            body: RefreshIndicator(
              onRefresh: () => viewModel.loadSchedule(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columnCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                  final itemWidth = (constraints.maxWidth - (columnCount + 1) * 16) / columnCount;
                  
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_showInfo) ...[
                        _buildInfoCard(context, itemWidth),
                      ],
                      Wrap(
                        spacing: 16,
                        children: viewModel.weekSchedule.map((day) {
                          return SizedBox(
                            width: itemWidth,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                                title: Text(
                                  day.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: day.exercises.isEmpty 
                                  ? const Text(
                                      'День отдыха'
                                    )
                                  : Text(
                                      '${day.exercises.length} ${_getExercisesWord(day.exercises.length)}',
                                    ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DayDetailView(
                                        day: day,
                                        onSave: (updatedDay) {
                                          viewModel.updateSchedule(updatedDay);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
} 