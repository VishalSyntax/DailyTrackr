import 'habit_type.dart';

class HabitItem {
  const HabitItem({
    required this.id,
    required this.name,
    required this.type,
    required this.isCompleted,
    required this.dateKey,
  });

  final String id;
  final String name;
  final HabitType type;
  final bool isCompleted;
  final String dateKey;

  HabitItem copyWith({
    String? id,
    String? name,
    HabitType? type,
    bool? isCompleted,
    String? dateKey,
  }) {
    return HabitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      dateKey: dateKey ?? this.dateKey,
    );
  }

  Map<String, dynamic> toCompletionMap() {
    return {
      'habitId': id,
      'name': name,
      'date': dateKey,
      'type': type.value,
      'isCompleted': isCompleted,
    };
  }
}
