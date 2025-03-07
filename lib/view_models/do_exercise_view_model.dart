import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../utilities/data_manager.dart';

class DoExerciseViewModel extends ChangeNotifier {
  final Exercise _exercise;
  final DataManager _dataManager;
  List<ExerciseSet> _actualSets = [];
  bool _isCompleted = false;
  int _currentTime = 0;
  bool _isTimerRunning = false;
  int _currentSetIndex = 0;
  bool _isResting = false;
  int _restTimeRemaining = 0;
  
  // Хранилище для контроллеров текстовых полей
  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, TextEditingController> _weightControllers = {};

  Exercise get exercise => _exercise;
  List<ExerciseSet> get actualSets => _actualSets;
  bool get isCompleted => _isCompleted;
  int get currentTime => _currentTime;
  bool get isTimerRunning => _isTimerRunning;
  bool get isResting => _isResting;
  int get restTimeRemaining => _restTimeRemaining;
  int get currentSetIndex => _currentSetIndex;

  set isTimerRunning(bool value) {
    _isTimerRunning = value;
    notifyListeners();
  }

  set currentTime(int value) {
    _currentTime = value;
    notifyListeners();
  }

  DoExerciseViewModel(this._exercise, {DataManager? dataManager}) 
      : _dataManager = dataManager ?? DataManager.instance {
    _init();
  }

  void _init() {
    if (_exercise.type == ExerciseType.repetitions && _exercise.sets != null) {
      // Инициализируем actualSets с целевым количеством повторений из упражнения
      _actualSets = _exercise.sets!.asMap().entries.map((entry) {
        final set = entry.value;
        // Используем количество повторений из упражнения как начальное значение
        return ExerciseSet(
          repetitions: set.repetitions,
          weight: set.weight ?? _exercise.weight
        );
      }).toList();
    }
  }
  
  // Метод для получения контроллера по индексу
  TextEditingController getTextController(int index) {
    if (!_textControllers.containsKey(index)) {
      _textControllers[index] = TextEditingController();
    }
    return _textControllers[index]!;
  }

  // Метод для получения контроллера веса по индексу
  TextEditingController getWeightController(int index) {
    if (!_weightControllers.containsKey(index)) {
      _weightControllers[index] = TextEditingController(
        text: _exercise.sets?[index].weight?.toString() ?? _exercise.weight?.toString() ?? '',
      );
    }
    return _weightControllers[index]!;
  }

  void updateActualSet(int index, {int? repetitions, int? weight}) {
    if (index >= 0 && index < _actualSets.length) {
      _actualSets[index] = ExerciseSet(
        id: _actualSets[index].id,
        repetitions: repetitions ?? _actualSets[index].repetitions,
        weight: weight ?? _actualSets[index].weight,
      );
      notifyListeners();
    }
  }

  // Метод для получения текущего количества повторений
  int getActualRepetitions(int index) {
    if (index >= 0 && index < _actualSets.length) {
      return _actualSets[index].repetitions;
    }
    return 0;
  }

  // Метод для получения текущего веса
  int getActualWeight(int index) {
    if (index >= 0 && index < _actualSets.length) {
      // Если у текущего подхода есть вес, возвращаем его
      if (_actualSets[index].weight != null) {
        return _actualSets[index].weight!;
      }
      // Иначе берем вес из соответствующего подхода в упражнении
      if (_exercise.sets != null && index < _exercise.sets!.length && _exercise.sets![index].weight != null) {
        return _exercise.sets![index].weight!;
      }
      // Или общий вес упражнения
      if (_exercise.weight != null) {
        return _exercise.weight!;
      }
    }
    // Если ничего не найдено, возвращаем значение по умолчанию
    return 10;
  }

  void startRestTimer() {
    if (_exercise.restTime != null && _exercise.restTime! > 0) {
      _isResting = true;
      _restTimeRemaining = _exercise.restTime!;
      notifyListeners();
    } else {
      _moveToNextSet();
    }
  }

  void updateRestTime(int time) {
    _restTimeRemaining = time;
    if (time == 0) {
      _isResting = false;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void _moveToNextSet() {
    if (_currentSetIndex < _actualSets.length - 1) {
      _currentSetIndex++;
    }
    notifyListeners();
  }

  void skipRest() {
    _isResting = false;
    _moveToNextSet();
    notifyListeners();
  }

  Future<void> completeExercise() async {
    _isCompleted = true;
    await _dataManager.recordLastExecuted(_exercise.id);
    
    if (_exercise.type == ExerciseType.repetitions) {
      for (var set in _actualSets) {
        await _dataManager.addExerciseResult(_exercise.id, set.repetitions);
      }
    } else if (_exercise.type == ExerciseType.time) {
      await _dataManager.addExerciseResult(_exercise.id, _currentTime);
    }
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров при уничтожении модели
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    for (var controller in _weightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
} 