enum HabitType {
  defaultHabit,
  custom,
  special,
}

extension HabitTypeMapper on HabitType {
  String get value {
    switch (this) {
      case HabitType.defaultHabit:
        return 'default';
      case HabitType.custom:
        return 'custom';
      case HabitType.special:
        return 'special';
    }
  }

  static HabitType fromValue(String value) {
    switch (value) {
      case 'custom':
        return HabitType.custom;
      case 'special':
        return HabitType.special;
      default:
        return HabitType.defaultHabit;
    }
  }
}
