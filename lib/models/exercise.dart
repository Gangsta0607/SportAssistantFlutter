import 'package:uuid/uuid.dart';

enum ExerciseType {
  time,
  repetitions;

  String get displayName {
    switch (this) {
      case ExerciseType.time:
        return 'Время';
      case ExerciseType.repetitions:
        return 'Повторения';
    }
  }

  static ExerciseType fromString(String value) {
    return ExerciseType.values.firstWhere(
      (e) => e.displayName == value,
      orElse: () => ExerciseType.repetitions,
    );
  }
}

class ExerciseSet {
  final String id;
  final int repetitions;
  final int? weight;

  ExerciseSet({
    String? id, 
    required this.repetitions,
    this.weight,
  }) : id = id ?? const Uuid().v4();

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'],
      repetitions: json['repetitions'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repetitions': repetitions,
      'weight': weight,
    };
  }

  ExerciseSet copyWith({
    int? repetitions,
    int? weight,
  }) {
    return ExerciseSet(
      id: id,
      repetitions: repetitions ?? this.repetitions,
      weight: weight ?? this.weight,
    );
  }
}

class Exercise {
  final String id;
  final String title;
  final ExerciseType type;
  final int? time;
  final List<ExerciseSet>? sets;
  final List<ExerciseSet>? actualSets;
  final String? inventory;
  final int? weight;
  final String? muscleGroup;
  final int? restTime;
  final DateTime? lastExecuted;

  bool get hasIdenticalSets {
    if (sets == null || sets!.isEmpty) return false;
    
    final firstReps = sets!.first.repetitions;
    final firstWeight = sets!.first.weight;
    
    return sets!.every((set) => 
      set.repetitions == firstReps && set.weight == firstWeight);
  }

  Exercise({
    String? id,
    required this.title,
    required this.type,
    this.time,
    this.sets,
    this.actualSets,
    this.inventory,
    this.weight,
    this.muscleGroup,
    this.restTime,
    this.lastExecuted,
  }) : id = id ?? const Uuid().v4();

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      type: ExerciseType.fromString(json['type']),
      time: json['time'],
      sets: json['sets'] != null
          ? List<ExerciseSet>.from(
              json['sets'].map((x) => ExerciseSet.fromJson(x)))
          : null,
      actualSets: json['actualSets'] != null
          ? List<ExerciseSet>.from(
              json['actualSets'].map((x) => ExerciseSet.fromJson(x)))
          : null,
      inventory: json['inventory'],
      weight: json['weight'],
      muscleGroup: json['muscleGroup'],
      restTime: json['restTime'],
      lastExecuted: json['lastExecuted'] != null
          ? DateTime.parse(json['lastExecuted'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.displayName,
      'time': time,
      'sets': sets?.map((x) => x.toJson()).toList(),
      'actualSets': actualSets?.map((x) => x.toJson()).toList(),
      'inventory': inventory,
      'weight': weight,
      'muscleGroup': muscleGroup,
      'restTime': restTime,
      'lastExecuted': lastExecuted?.toIso8601String(),
    };
  }

  Exercise copyWith({
    String? title,
    ExerciseType? type,
    int? time,
    List<ExerciseSet>? sets,
    List<ExerciseSet>? actualSets,
    String? inventory,
    int? weight,
    String? muscleGroup,
    int? restTime,
    DateTime? lastExecuted,
  }) {
    return Exercise(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      time: time ?? this.time,
      sets: sets ?? this.sets,
      actualSets: actualSets ?? this.actualSets,
      inventory: inventory ?? this.inventory,
      weight: weight ?? this.weight,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      restTime: restTime ?? this.restTime,
      lastExecuted: lastExecuted ?? this.lastExecuted,
    );
  }
} 