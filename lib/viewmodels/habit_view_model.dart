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

  void setTab(int index) {
    if (_selectedTabIndex == index) {
      return;
    }
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> refreshForNewDay() async {
    final now = DateTime.now();
    final isNewDay =
        now.year != _today.year || now.month != _today.month || now.day != _today.day;

    if (!isNewDay) {
      return;
    }

    _normalizeToday();
    _selectedCalendarDate = _today;
    await _loadAllData();
    notifyListeners();
  }

  Future<void> toggleTodayHabit(int index, bool value) async {
    if (index < 0 || index >= _todayHabits.length) {
      return;
    }

    final habit = _todayHabits[index];
    await _storageService.setHabitCompletion(
      habit: habit,
      date: _today,
      isCompleted: value,
    );

    await _loadTodayHabits();
    await _loadAnalytics();
    notifyListeners();
  }

  Future<void> toggleCalendarHabit(int index, bool value) async {
    if (index < 0 || index >= _calendarHabits.length) {
      return;
    }

    final habit = _calendarHabits[index];
    await _storageService.setHabitCompletion(
      habit: habit,
      date: _selectedCalendarDate,
      isCompleted: value,
    );

    await _loadCalendarHabits();
    await _loadTodayHabits();
    await _loadAnalytics();
    notifyListeners();
  }

  
}
