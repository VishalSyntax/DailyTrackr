import 'package:flutter/material.dart';

import '../models/analytics_summary.dart';
import '../models/habit_item.dart';
import '../services/habit_storage_service.dart';

class HabitViewModel extends ChangeNotifier {
  HabitViewModel({required HabitStorageService storageService})
      : _storageService = storageService;

  final HabitStorageService _storageService;

  int _selectedTabIndex = 0;
  bool _isLoading = true;

  DateTime _today = DateTime.now();
  DateTime _selectedCalendarDate = DateTime.now();

  List<HabitItem> _todayHabits = const [];
  List<HabitItem> _calendarHabits = const [];

  AnalyticsSummary _weeklySummary = const AnalyticsSummary(
    totalCompleted: 0,
    totalHabits: 0,
  );
  AnalyticsSummary _monthlySummary = const AnalyticsSummary(
    totalCompleted: 0,
    totalHabits: 0,
  );

  int _streakCount = 0;

  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  DateTime get today => _today;
  DateTime get selectedCalendarDate => _selectedCalendarDate;
  List<HabitItem> get todayHabits => _todayHabits;
  List<HabitItem> get calendarHabits => _calendarHabits;
  AnalyticsSummary get weeklySummary => _weeklySummary;
  AnalyticsSummary get monthlySummary => _monthlySummary;
  int get streakCount => _streakCount;

  int get completedTodayCount {
    return _todayHabits.where((habit) => habit.isCompleted).length;
  }

  double get todayProgress {
    if (_todayHabits.isEmpty) {
      return 0;
    }
    return completedTodayCount / _todayHabits.length;
  }

  List<HabitItem> get completedHabitsForSelectedDate {
    return _calendarHabits.where((habit) => habit.isCompleted).toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    _normalizeToday();
    await _loadAllData();
    _isLoading = false;
    notifyListeners();
  }

  

  
}
