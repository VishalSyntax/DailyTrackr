import '../models/analytics_summary.dart';
import '../models/habit_item.dart';

abstract class HabitStorageService {
  Future<List<HabitItem>> getHabitsForDate(DateTime date);

  Future<void> setHabitCompletion({
    required HabitItem habit,
    required DateTime date,
    required bool isCompleted,
  });

  Future<void> addCustomHabit(String name);

  Future<void> addSpecialTask({
    required String name,
    required DateTime date,
  });

  Future<AnalyticsSummary> getSummary({
    required DateTime start,
    required DateTime end,
  });

  Future<int> getCurrentStreak({required DateTime fromDate});
}
