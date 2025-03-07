import 'package:flutter/foundation.dart';
import '../models/day.dart';
import '../utilities/data_manager.dart';

class HomeViewModel extends ChangeNotifier {
  Day _todaySchedule = Day(name: 'Сегодня');
  Day _tomorrowSchedule = Day(name: 'Завтра');
  final DataManager _dataManager;
  bool _isLoading = true;

  Day get todaySchedule => _todaySchedule;
  Day get tomorrowSchedule => _tomorrowSchedule;
  bool get isLoading => _isLoading;

  // Кэш для хранения статуса выполнения упражнений
  final Map<String, bool> _exerciseCompletionCache = {};

  HomeViewModel({DataManager? dataManager}) 
      : _dataManager = dataManager ?? DataManager.instance {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final weekSchedule = await _dataManager.loadSchedule();
      _todaySchedule = weekSchedule[getCurrentDayOfWeekForBelarus()];
      _tomorrowSchedule = weekSchedule[getNextDayOfWeekForBelarus()];
      
      // Очищаем кэш при загрузке новых данных
      _exerciseCompletionCache.clear();
      
      // Предварительно загружаем статусы выполнения для всех упражнений
      await _preloadExerciseCompletionStatus();
    } catch (e) {
      debugPrint('Ошибка при загрузке расписания: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _preloadExerciseCompletionStatus() async {
    // Загружаем статусы для упражнений на сегодня
    for (final exercise in _todaySchedule.exercises) {
      final lastDate = await _dataManager.getLastExecutedDate(exercise.id);
      _exerciseCompletionCache[exercise.id] = sameDate(lastDate);
    }
  }

  bool isExerciseCompleted(String exerciseId) {
    // Используем кэш, если данные уже загружены
    if (_exerciseCompletionCache.containsKey(exerciseId)) {
      return _exerciseCompletionCache[exerciseId]!;
    }
    // Если данных нет в кэше, возвращаем false
    return false;
  }

  int getCurrentDayOfWeekForBelarus() {
    final now = DateTime.now();
    int dayOfWeek = now.weekday - 1; // 0 - понедельник, 6 - воскресенье
    return dayOfWeek;
  }

  int getNextDayOfWeekForBelarus() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    int dayOfWeek = tomorrow.weekday - 1; // 0 - понедельник, 6 - воскресенье
    return dayOfWeek;
  }

  bool sameDate(DateTime? lastExecutedDate) {
    if (lastExecutedDate == null) return false;
    final now = DateTime.now();
    return lastExecutedDate.year == now.year && 
           lastExecutedDate.month == now.month && 
           lastExecutedDate.day == now.day;
  }

  Future<DateTime?> getLastExecutedDate(String uuid) async {
    // Проверяем, есть ли данные в кэше
    if (_exerciseCompletionCache.containsKey(uuid)) {
      // Если упражнение выполнено сегодня, возвращаем текущую дату
      if (_exerciseCompletionCache[uuid]!) {
        return DateTime.now();
      }
    }
    
    // Если нет в кэше или не выполнено, запрашиваем из хранилища
    final date = await _dataManager.getLastExecutedDate(uuid);
    
    // Обновляем кэш
    _exerciseCompletionCache[uuid] = sameDate(date);
    
    return date;
  }
} 