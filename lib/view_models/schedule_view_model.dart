import 'package:flutter/foundation.dart';
import '../models/day.dart';
import '../utilities/data_manager.dart';

class ScheduleViewModel extends ChangeNotifier {
  List<Day> _weekSchedule = [];
  final DataManager _dataManager;

  List<Day> get weekSchedule => _weekSchedule;

  ScheduleViewModel({DataManager? dataManager}) 
      : _dataManager = dataManager ?? DataManager.instance {
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    _weekSchedule = await _dataManager.loadSchedule();
    notifyListeners();
  }

  Future<void> updateSchedule(Day day) async {
    await _dataManager.updateSchedule(day);
    await loadSchedule();
  }

  int? getDayIndex(String dayName) {
    return _weekSchedule.indexWhere((day) => day.name == dayName);
  }
} 