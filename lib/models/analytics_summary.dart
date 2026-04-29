class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalCompleted,
    required this.totalHabits,
  });

  final int totalCompleted;
  final int totalHabits;

  double get completionPercentage {
    if (totalHabits == 0) {
      return 0;
    }
    return (totalCompleted / totalHabits) * 100;
  }
}
