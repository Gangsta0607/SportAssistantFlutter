import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/exercise.dart';

enum SetType {
  same,
  different;

  String get displayName {
    switch (this) {
      case SetType.same:
        return 'Одинаковые подходы';
      case SetType.different:
        return 'Разные подходы';
    }
  }
}

class AddExerciseViewModel extends ChangeNotifier {
  String _title = '';
  ExerciseType _type = ExerciseType.repetitions;
  int? _time;
  List<ExerciseSet> _sets = [];
  String? _inventory;
  int? _weight;
  String? _muscleGroup;
  int? _restTime = 120;
  SetType _setType = SetType.same;
  int _numberOfSets = 4;
  int _repetitionsPerSet = 10;
  String? _exerciseId;
  
  // Новые поля для управления инвентарем и разными весами
  bool _hasInventory = false;
  bool _hasDifferentWeights = false;
  
  // Флаги для отображения ошибок валидации
  bool _showTitleError = false;
  bool _showTimeError = false;
  bool _showSetsError = false;
  Timer? _errorTimer;

  // Конструктор с инициализацией подходов по умолчанию
  AddExerciseViewModel({Exercise? initialExercise}) {
    if (initialExercise != null) {
      _initFromExercise(initialExercise);
    } else {
      // Генерируем 4 подхода по 10 повторений по умолчанию
      generateSameSets();
    }
  }
  
  void _initFromExercise(Exercise exercise) {
    _exerciseId = exercise.id;
    _title = exercise.title;
    _type = exercise.type;
    _time = exercise.time;
    _sets = exercise.sets?.toList() ?? [];
    _inventory = exercise.inventory;
    _weight = exercise.weight;
    _muscleGroup = exercise.muscleGroup;
    _restTime = exercise.restTime ?? 120;
    
    // Определяем тип подходов
    if (_sets.isNotEmpty) {
      // Проверяем, все ли подходы одинаковые
      bool areSetsIdentical = true;
      int? firstReps = _sets.first.repetitions;
      int? firstWeight = _sets.first.weight;
      
      for (var set in _sets) {
        if (set.repetitions != firstReps || set.weight != firstWeight) {
          areSetsIdentical = false;
          break;
        }
      }
      
      if (areSetsIdentical) {
        _setType = SetType.same;
        _numberOfSets = _sets.length;
        _repetitionsPerSet = _sets.first.repetitions;
      } else {
        _setType = SetType.different;
      }
    }
    
    // Устанавливаем флаги инвентаря и разных весов
    _hasInventory = exercise.inventory != null || exercise.weight != null;
    
    // Проверяем, есть ли разные веса в подходах
    if (_sets.isNotEmpty) {
      bool hasDifferentWeightsInSets = false;
      int? firstWeight = _sets.first.weight;
      
      for (var set in _sets) {
        if (set.weight != firstWeight) {
          hasDifferentWeightsInSets = true;
          break;
        }
      }
      
      _hasDifferentWeights = hasDifferentWeightsInSets;
    }
  }

  String get title => _title;
  ExerciseType get type => _type;
  int? get time => _time;
  List<ExerciseSet> get sets => _sets;
  String? get inventory => _inventory;
  int? get weight => _weight;
  String? get muscleGroup => _muscleGroup;
  int? get restTime => _restTime;
  SetType get setType => _setType;
  int get numberOfSets => _numberOfSets;
  int get repetitionsPerSet => _repetitionsPerSet;
  bool get showTitleError => _showTitleError;
  bool get showTimeError => _showTimeError;
  bool get showSetsError => _showSetsError;
  bool get isEditing => _exerciseId != null;
  
  // Геттеры для новых полей
  bool get hasInventory => _hasInventory;
  bool get hasDifferentWeights => _hasDifferentWeights;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  set type(ExerciseType value) {
    _type = value;
    // Сбрасываем флаг разных весов, если тип упражнения - время
    if (value == ExerciseType.time) {
      _hasDifferentWeights = false;
    }
    notifyListeners();
  }

  set time(int? value) {
    _time = value;
    notifyListeners();
  }

  set inventory(String? value) {
    _inventory = value;
    notifyListeners();
  }

  set weight(int? value) {
    _weight = value;
    // Если установлен вес, но не установлен флаг инвентаря, устанавливаем его
    if (value != null && !_hasInventory) {
      _hasInventory = true;
    }
    notifyListeners();
  }

  set muscleGroup(String? value) {
    _muscleGroup = value;
    notifyListeners();
  }

  set restTime(int? value) {
    _restTime = value;
    notifyListeners();
  }

  set setType(SetType value) {
    _setType = value;
    if (value == SetType.same) {
      generateSameSets();
    } else {
      generateDifferentSets();
    }
    notifyListeners();
  }

  set numberOfSets(int value) {
    _numberOfSets = value;
    notifyListeners();
  }

  set repetitionsPerSet(int value) {
    _repetitionsPerSet = value;
    notifyListeners();
  }

  set hasInventory(bool value) {
    _hasInventory = value;
    if (!value) {
      _inventory = null;
      _weight = null;
    }
    notifyListeners();
  }
  
  set hasDifferentWeights(bool value) {
    _hasDifferentWeights = value;
    if (value) {
      if (_setType == SetType.different) {
        // Обновляем веса для каждого подхода
        _sets = _sets.map((set) => 
          set.copyWith(weight: set.weight ?? 10)
        ).toList();
      } else {
        // Для одинаковых подходов тоже устанавливаем индивидуальные веса
        generateSameSets();
      }
    } else if (_setType == SetType.same) {
      // Если отключаем разные веса для одинаковых подходов, обновляем подходы
      generateSameSets();
    }
    notifyListeners();
  }

  void addSet(int repetitions) {
    _sets.add(ExerciseSet(repetitions: repetitions));
    notifyListeners();
  }

  void removeSet(int index) {
    if (index >= 0 && index < _sets.length) {
      _sets.removeAt(index);
      notifyListeners();
    }
  }

  void updateSet(int index, int repetitions) {
    if (index >= 0 && index < _sets.length) {
      final currentSet = _sets[index];
      _sets[index] = ExerciseSet(
        id: currentSet.id,
        repetitions: repetitions,
        weight: currentSet.weight,
      );
      notifyListeners();
    }
  }

  void updateSetWeight(int index, int weight) {
    if (index >= 0 && index < _sets.length) {
      final currentSet = _sets[index];
      _sets[index] = ExerciseSet(
        id: currentSet.id,
        repetitions: currentSet.repetitions,
        weight: weight,
      );
      notifyListeners();
    }
  }

  void generateSameSets() {
    final newSets = <ExerciseSet>[];
    for (var i = 0; i < _numberOfSets; i++) {
      // Если включен режим разных весов, то каждому подходу назначаем вес 10 кг
      // Если у нас уже есть подходы, сохраняем их веса
      int? setWeight;
      if (_hasDifferentWeights) {
        // Если у нас уже есть подходы, используем их веса или 10 по умолчанию
        setWeight = (i < _sets.length) ? (_sets[i].weight ?? 10) : 10;
      } else {
        // Если режим разных весов выключен, используем общий вес
        setWeight = _weight;
      }
      
      newSets.add(ExerciseSet(
        repetitions: _repetitionsPerSet,
        weight: setWeight,
      ));
    }
    _sets = newSets;
    notifyListeners();
  }

  void generateDifferentSets() {
    // Сохраняем текущие подходы, если они есть
    final currentSets = List<ExerciseSet>.from(_sets);
    
    // Создаем новый список подходов
    final newSets = <ExerciseSet>[];
    
    // Добавляем существующие подходы или создаем новые
    for (var i = 0; i < _numberOfSets; i++) {
      if (i < currentSets.length) {
        // Используем существующий подход, но обновляем вес, если нужно
        newSets.add(currentSets[i].copyWith(
          weight: _hasDifferentWeights ? (currentSets[i].weight ?? 10) : null
        ));
      } else {
        // Создаем новый подход
        newSets.add(ExerciseSet(
          repetitions: 10,
          weight: _hasDifferentWeights ? 10 : null,
        ));
      }
    }
    
    _sets = newSets;
    notifyListeners();
  }

  bool validateExercise() {
    bool isValid = true;
    
    // Проверка названия
    if (_title.isEmpty) {
      isValid = false;
    }
    
    // Проверка в зависимости от типа упражнения
    if (_type == ExerciseType.time) {
      if (_time == null || _time! <= 0) {
        isValid = false;
      }
    } else {
      if (_sets.isEmpty) {
        isValid = false;
      }
    }
    
    return isValid;
  }
  
  // Метод для проверки и отображения ошибок
  bool validateAndShowErrors() {
    bool isValid = true;
    
    // Сбрасываем предыдущие ошибки
    _showTitleError = false;
    _showTimeError = false;
    _showSetsError = false;
    
    // Проверка названия
    if (_title.isEmpty) {
      _showTitleError = true;
      isValid = false;
    }
    
    // Проверка в зависимости от типа упражнения
    if (_type == ExerciseType.time) {
      if (_time == null || _time! <= 0) {
        _showTimeError = true;
        isValid = false;
      }
    } else {
      if (_sets.isEmpty) {
        _showSetsError = true;
        isValid = false;
      }
    }
    
    // Если есть ошибки, запускаем таймер для их скрытия через 5 секунд
    if (!isValid) {
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(seconds: 5), () {
        _showTitleError = false;
        _showTimeError = false;
        _showSetsError = false;
        notifyListeners();
      });
      notifyListeners();
    }
    
    return isValid;
  }

  Exercise createExercise() {
    return Exercise(
      id: _exerciseId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title,
      type: _type,
      time: _type == ExerciseType.time ? _time : null,
      sets: _type == ExerciseType.repetitions ? _sets : null,
      inventory: _hasInventory && _inventory?.isNotEmpty == true ? _inventory : null,
      weight: _hasInventory && !_hasDifferentWeights ? _weight : null,
      muscleGroup: _muscleGroup?.isNotEmpty == true ? _muscleGroup : null,
      restTime: _type == ExerciseType.time ? null : _restTime,
    );
  }

  void reset() {
    _title = '';
    _type = ExerciseType.repetitions;
    _time = null;
    _sets = [];
    _inventory = null;
    _weight = null;
    _muscleGroup = null;
    _restTime = 120;
    _setType = SetType.same;
    _numberOfSets = 4;
    _repetitionsPerSet = 10;
    _showTitleError = false;
    _showTimeError = false;
    _showSetsError = false;
    _hasInventory = false;
    _hasDifferentWeights = false;
    generateSameSets();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
} 