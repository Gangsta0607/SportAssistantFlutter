import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../utilities/data_manager.dart';

class ExerciseHistoryViewModel extends ChangeNotifier {
  final Exercise _exercise;
  final DataManager _dataManager;
  List<int>? _historyResults;
  bool _isLoading = true;

  Exercise get exercise => _exercise;
  List<int>? get historyResults => _historyResults;
  bool get isLoading => _isLoading;

  ExerciseHistoryViewModel(this._exercise, {DataManager? dataManager}) 
      : _dataManager = dataManager ?? DataManager.instance {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _isLoading = true;
    notifyListeners();
    
    final rawResults = await _dataManager.getExerciseResult(_exercise.id);
    
    if (rawResults != null && rawResults.isNotEmpty) {
      if (_exercise.type == ExerciseType.repetitions) {
        // Для упражнений с подходами нам нужно обработать результаты
        // Если упражнение имеет подходы, то результаты сохраняются для каждого подхода отдельно
        // Нам нужно сгруппировать их по тренировкам и суммировать
        
        // Определяем количество подходов в упражнении
        final setsCount = _exercise.sets?.length ?? 1;
        
        if (setsCount > 1) {
          // Если у нас несколько подходов, группируем результаты по тренировкам
          final List<int> processedResults = [];
          
          // Проходим по результатам с шагом, равным количеству подходов
          for (int i = 0; i < rawResults.length; i += setsCount) {
            int totalReps = 0;
            
            // Суммируем повторения для всех подходов в одной тренировке
            for (int j = 0; j < setsCount && i + j < rawResults.length; j++) {
              totalReps += rawResults[i + j];
            }
            
            processedResults.add(totalReps);
          }
          
          _historyResults = processedResults;
        } else {
          // Если у нас один подход, просто используем результаты как есть
          _historyResults = rawResults;
        }
      } else {
        // Для упражнений на время просто используем результаты как есть
        _historyResults = rawResults;
      }
    } else {
      _historyResults = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _dataManager.removeExerciseResult(_exercise.id);
    _historyResults = null;
    notifyListeners();
  }
} 