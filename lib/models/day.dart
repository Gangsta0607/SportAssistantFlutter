import 'package:uuid/uuid.dart';
import 'exercise.dart';

class Day {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Day({
    String? id,
    required this.name,
    List<Exercise>? exercises,
  })  : id = id ?? const Uuid().v4(),
        exercises = exercises ?? [];

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'],
      name: json['name'],
      exercises: json['exercises'] != null
          ? List<Exercise>.from(
              json['exercises'].map((x) => Exercise.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((x) => x.toJson()).toList(),
    };
  }

  Day copyWith({
    String? name,
    List<Exercise>? exercises,
  }) {
    return Day(
      id: id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
} 