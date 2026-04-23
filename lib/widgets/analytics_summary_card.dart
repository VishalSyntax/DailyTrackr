import 'package:flutter/material.dart';

import '../models/analytics_summary.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({
    super.key,
    required this.title,
    required this.summary,
  });

  final String title;
  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Completed: ${summary.totalCompleted}'),
            Text('Total Habits: ${summary.totalHabits}'),
            Text(
              'Completion: ${summary.completionPercentage.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }
}
