import 'package:daily_trackr/main.dart';
import 'package:daily_trackr/models/analytics_summary.dart';
import 'package:daily_trackr/models/habit_item.dart';
import 'package:daily_trackr/models/habit_type.dart';
import 'package:daily_trackr/services/habit_storage_service.dart';
import 'package:daily_trackr/viewmodels/habit_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows app shell with bottom tabs', (tester) async {
    final viewModel = HabitViewModel(storageService: _FakeStorageService());

    await tester.pumpWidget(DailyTrackrApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('Habit Tracker'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('What did you complete today?'), findsOneWidget);
  });
}

class _FakeStorageService implements HabitStorageService {
  @override
  Future<void> addCustomHabit(String name) async {}

  @override
  Future<void> addSpecialTask({required String name, required DateTime date}) async {}

  @override
  Future<int> getCurrentStreak({required DateTime fromDate}) async => 0;

  @override
  Future<List<HabitItem>> getHabitsForDate(DateTime date) async {
    final dateKey = _toDateKey(date);
    return [
      HabitItem(
        id: 'default_drink_water',
        name: 'Drink Water',
        type: HabitType.defaultHabit,
        isCompleted: false,
        dateKey: dateKey,
      ),
      HabitItem(
        id: 'default_study',
        name: 'Study',
        type: HabitType.defaultHabit,
        isCompleted: false,
        dateKey: dateKey,
      ),
      HabitItem(
        id: 'default_reading',
        name: 'Reading',
        type: HabitType.defaultHabit,
        isCompleted: false,
        dateKey: dateKey,
      ),
    ];
  }

  @override
  Future<void> setHabitCompletion({
    required HabitItem habit,
    required DateTime date,
    required bool isCompleted,
  }) async {}

  @override
  Future<AnalyticsSummary> getSummary({
    required DateTime start,
    required DateTime end,
  }) async {
    return const AnalyticsSummary(totalCompleted: 0, totalHabits: 3);
  }

  String _toDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
