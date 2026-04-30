import 'package:flutter/material.dart';

import '../models/habit_item.dart';
import '../models/habit_type.dart';

class HabitCheckboxTile extends StatelessWidget {
  const HabitCheckboxTile({
    super.key,
    required this.habit,
    required this.onChanged,
  });

  final HabitItem habit;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: habit.isCompleted,
        onChanged: onChanged,
        title: Text(habit.name),
        subtitle: Text(_typeLabel(habit.type)),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  String _typeLabel(HabitType type) {
    switch (type) {
      case HabitType.defaultHabit:
        return 'Default Habit';
      case HabitType.custom:
        return 'Custom Habit';
      case HabitType.special:
        return 'Special Task';
    }
  }
}
