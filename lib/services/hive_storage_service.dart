import 'package:hive/hive.dart';

import '../models/analytics_summary.dart';
import '../models/habit_item.dart';
import '../models/habit_type.dart';
import 'habit_storage_service.dart';

class HiveStorageService implements HabitStorageService {
  HiveStorageService(this._box);

  static const String boxName = 'habit_tracker_box';
  static const String _customHabitsKey = 'custom_habits_v1';
  static const String _specialTasksKey = 'special_tasks_v1';
  static const String _completionKey = 'completion_records_v1';

  final Box<dynamic> _box;

  static const List<Map<String, String>> _defaultHabits = [
    {'id': 'default_drink_water', 'name': 'Drink Water'},
    {'id': 'default_study', 'name': 'Study'},
    {'id': 'default_reading', 'name': 'Reading'},
  ];

  @override
  Future<List<HabitItem>> getHabitsForDate(DateTime date) async {
    final dateKey = _toDateKey(date);

    final allHabits = <HabitItem>[
      ..._buildDefaultHabits(dateKey),
      ..._buildCustomHabits(dateKey),
      ..._buildSpecialHabits(dateKey),
    ];

    final records = _getCompletionRecords();
    final recordMap = <String, bool>{};

    for (final record in records) {
      final recordDate = record['date'];
      final habitId = record['habitId'];
      final isCompleted = record['isCompleted'];

      if (recordDate is String &&
          habitId is String &&
          recordDate == dateKey &&
          isCompleted is bool) {
        recordMap[habitId] = isCompleted;
      }
    }

    return allHabits
        .map(
          (habit) => habit.copyWith(
            isCompleted: recordMap[habit.id] ?? false,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> setHabitCompletion({
    required HabitItem habit,
    required DateTime date,
    required bool isCompleted,
  }) async {
    final dateKey = _toDateKey(date);
    final records = _getCompletionRecords();

    final index = records.indexWhere(
      (record) =>
          record['habitId'] == habit.id &&
          record['date'] == dateKey,
    );

    final updatedRecord = habit
        .copyWith(dateKey: dateKey, isCompleted: isCompleted)
        .toCompletionMap();

    if (index >= 0) {
      records[index] = updatedRecord;
    } else {
      records.add(updatedRecord);
    }

    await _box.put(_completionKey, records);
  }

  @override
  Future<void> addCustomHabit(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final customHabits = _getCustomHabits();
    customHabits.add({
      'id': 'custom_${DateTime.now().microsecondsSinceEpoch}',
      'name': trimmedName,
    });

    await _box.put(_customHabitsKey, customHabits);
  }

  @override
  Future<void> addSpecialTask({
    required String name,
    required DateTime date,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final specialTasks = _getSpecialTasks();
    specialTasks.add({
      'id': 'special_${DateTime.now().microsecondsSinceEpoch}',
      'name': trimmedName,
      'date': _toDateKey(date),
    });

    await _box.put(_specialTasksKey, specialTasks);
  }

  @override
  Future<AnalyticsSummary> getSummary({
    required DateTime start,
    required DateTime end,
  }) async {
    final days = _daysBetweenInclusive(start, end);
    var totalCompleted = 0;
    var totalHabits = 0;

    for (final day in days) {
      final habits = await getHabitsForDate(day);
      totalHabits += habits.length;
      totalCompleted += habits.where((habit) => habit.isCompleted).length;
    }

    return AnalyticsSummary(
      totalCompleted: totalCompleted,
      totalHabits: totalHabits,
    );
  }

  @override
  Future<int> getCurrentStreak({required DateTime fromDate}) async {
    var streak = 0;
    var day = DateTime(fromDate.year, fromDate.month, fromDate.day);

    while (true) {
      final habits = await getHabitsForDate(day);
      if (habits.isEmpty) {
        break;
      }

      final allCompleted = habits.every((habit) => habit.isCompleted);
      if (!allCompleted) {
        break;
      }

      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<HabitItem> _buildDefaultHabits(String dateKey) {
    return _defaultHabits
        .map(
          (habit) => HabitItem(
            id: habit['id']!,
            name: habit['name']!,
            type: HabitType.defaultHabit,
            isCompleted: false,
            dateKey: dateKey,
          ),
        )
        .toList(growable: false);
  }

  List<HabitItem> _buildCustomHabits(String dateKey) {
    final customHabits = _getCustomHabits();

    return customHabits
        .where((item) => item['id'] is String && item['name'] is String)
        .map(
          (item) => HabitItem(
            id: item['id'] as String,
            name: item['name'] as String,
            type: HabitType.custom,
            isCompleted: false,
            dateKey: dateKey,
          ),
        )
        .toList(growable: false);
  }

  List<HabitItem> _buildSpecialHabits(String dateKey) {
    final specialTasks = _getSpecialTasks();

    return specialTasks
        .where(
          (item) =>
              item['id'] is String &&
              item['name'] is String &&
              item['date'] == dateKey,
        )
        .map(
          (item) => HabitItem(
            id: item['id'] as String,
            name: item['name'] as String,
            type: HabitType.special,
            isCompleted: false,
            dateKey: dateKey,
          ),
        )
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _getCustomHabits() {
    return _readListOfMaps(_customHabitsKey);
  }

  List<Map<String, dynamic>> _getSpecialTasks() {
    return _readListOfMaps(_specialTasksKey);
  }

  List<Map<String, dynamic>> _getCompletionRecords() {
    return _readListOfMaps(_completionKey);
  }

  List<Map<String, dynamic>> _readListOfMaps(String key) {
    final raw = _box.get(key);
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    final output = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        output.add(Map<String, dynamic>.from(item));
      }
    }

    return output;
  }

  List<DateTime> _daysBetweenInclusive(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    if (normalizedEnd.isBefore(normalizedStart)) {
      return const [];
    }

    final days = <DateTime>[];
    var day = normalizedStart;
    while (!day.isAfter(normalizedEnd)) {
      days.add(day);
      day = day.add(const Duration(days: 1));
    }

    return days;
  }

  String _toDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
