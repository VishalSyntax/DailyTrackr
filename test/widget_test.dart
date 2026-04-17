import 'package:daily_trackr/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adds a new daily task', (tester) async {
    final storage = FakeTaskStorage();

    await tester.pumpWidget(DailyTrackrApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskInput')), 'Drink water');
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Drink water'), findsOneWidget);
    expect(storage.savedTasks.single.title, 'Drink water');
    expect(storage.savedTasks.single.isCompleted, isFalse);
  });

  testWidgets('marks a task as completed', (tester) async {
    final storage = FakeTaskStorage(
      initialTasks: const [Task(title: 'Walk', isCompleted: false)],
    );

    await tester.pumpWidget(DailyTrackrApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isTrue);
    expect(storage.savedTasks.single.isCompleted, isTrue);
  });
}

class FakeTaskStorage implements TaskStorage {
  FakeTaskStorage({List<Task>? initialTasks})
      : _initialTasks = initialTasks ?? const [];

  final List<Task> _initialTasks;
  List<Task> savedTasks = const [];

  @override
  Future<List<Task>> loadTasks() async => _initialTasks;

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    savedTasks = List<Task>.from(tasks);
  }
}
