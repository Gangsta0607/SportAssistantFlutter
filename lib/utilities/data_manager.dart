import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day.dart';
import 'package:flutter/material.dart';
import 'server_sync_manager.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  static DataManager get instance => _instance;

  DataManager._internal();

  // Ключ для хранения данных
  final String _dataKey = 'appData';
  
  // Кэш данных в памяти
  Map<String, dynamic> _cache = {
    'schedule': <Day>[],
    'lastExecuted': <String, String>{},
    'results': <String, List<int>>{},
  };

  // Флаг для отслеживания изменений
  bool _isDirty = false;

  final List<String> weekDays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье'
  ];

  // Инициализация кэша при первом обращении
  Future<void> _initializeCache() async {
    if (_cache['schedule'].isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_dataKey);
      
      if (jsonData != null) {
        final data = jsonDecode(jsonData);
        _cache = {
          'schedule': (data['schedule'] as List).map((item) => Day.fromJson(item)).toList(),
          'lastExecuted': Map<String, String>.from(data['lastExecuted'] ?? {}),
          'results': Map<String, List<int>>.from(
            (data['results'] ?? {}).map((key, value) => 
              MapEntry(key, (value as List).map((e) => int.parse(e.toString())).toList())
            )
          ),
        };
      } else {
        _cache['schedule'] = weekDays.map((name) => Day(name: name)).toList();
      }
    }
  }

  // Сохранение всех данных
  Future<void> _saveData() async {
    if (!_isDirty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'schedule': _cache['schedule'].map((day) => day.toJson()).toList(),
      'lastExecuted': _cache['lastExecuted'],
      'results': _cache['results'].map((key, value) => 
        MapEntry(key, value.map((e) => e.toString()).toList())
      ),
    };
    
    await prefs.setString(_dataKey, jsonEncode(data));
    _isDirty = false;
  }

  Future<void> updateSchedule(Day day) async {
    await _initializeCache();
    final index = weekDays.indexOf(day.name);
    if (index != -1) {
      (_cache['schedule'] as List<Day>)[index] = day;
      _isDirty = true;
      await _saveData();
    }
  }

  Future<List<Day>> loadSchedule() async {
    await _initializeCache();
    return List<Day>.from(_cache['schedule']);
  }

  Future<void> addExerciseResult(String uuid, int value) async {
    await _initializeCache();
    final results = _cache['results'] as Map<String, List<int>>;
    if (!results.containsKey(uuid)) {
      results[uuid] = [];
    }
    results[uuid]!.add(value);
    
    await recordLastExecuted(uuid);
    _isDirty = true;
    await _saveData();
  }

  Future<void> removeExerciseResult(String uuid) async {
    await _initializeCache();
    (_cache['results'] as Map<String, List<int>>).remove(uuid);
    await recordLastExecuted(uuid, true);
    _isDirty = true;
    await _saveData();
  }

  Future<void> clearAllProgress() async {
    await _initializeCache();
    final uuids = List<String>.from(_cache['schedule'].map((day) => day.exercises.map((e) => e.id).join(',')));
    _cache['results'].clear();
    _cache['lastExecuted'].clear();
    
    for (var uuid in uuids) {
      await recordLastExecuted(uuid, true);
    }
    
    _isDirty = true;
    await _saveData();
  }

  Future<List<int>?> getExerciseResult(String uuid) async {
    await _initializeCache();
    return (_cache['results'] as Map<String, List<int>>)[uuid];
  }

  Future<void> recordLastExecuted(String uuid, [bool? reset]) async {
    await _initializeCache();
    final lastExecuted = _cache['lastExecuted'] as Map<String, String>;
    
    if (reset != null) {
      lastExecuted.remove(uuid);
    } else {
      lastExecuted[uuid] = DateTime.now().toIso8601String();
    }
    
    _isDirty = true;
    await _saveData();
  }

  Future<DateTime?> getLastExecutedDate(String uuid) async {
    await _initializeCache();
    final dateString = (_cache['lastExecuted'] as Map<String, String>)[uuid];
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  Future<void> clearEverything() async {
    _cache = {
      'schedule': weekDays.map((name) => Day(name: name)).toList(),
      'lastExecuted': <String, String>{},
      'results': <String, List<int>>{},
    };
    _isDirty = true;
    await _saveData();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> syncToServer(BuildContext context) async {
    try {
      final data = {
        'schedule': _cache['schedule'].map((day) => day.toJson()).toList(),
        'lastExecuted': _cache['lastExecuted'],
        'results': _cache['results'].map((key, value) => 
          MapEntry(key, value.map((e) => e.toString()).toList())
        ),
      };

      final success = await ServerSyncManager.syncToServer(data);
      
      if (!context.mounted) return success;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные успешно отправлены на сервер'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при отправке данных на сервер'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      return success;
    } catch (e) {
      if (!context.mounted) return false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> syncFromServer(BuildContext context) async {
    try {
      final data = await ServerSyncManager.syncFromServer();
      
      _cache['schedule'] = (data['schedule'] as List).map((item) => Day.fromJson(item)).toList();
      _cache['lastExecuted'] = Map<String, String>.from(data['lastExecuted'] ?? {});
      _cache['results'] = Map<String, List<int>>.from(
        (data['results'] ?? {}).map((key, value) => 
          MapEntry(key, (value as List).map((e) => int.parse(e.toString())).toList())
        )
      );
      
      _isDirty = true;
      await _saveData();
      
      if (!context.mounted) return true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно получены с сервера'),
          backgroundColor: Colors.green,
        ),
      );
      
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
} 