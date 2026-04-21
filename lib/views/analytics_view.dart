import 'package:flutter/material.dart';

import '../viewmodels/habit_view_model.dart';
import '../widgets/analytics_summary_card.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({
    super.key,
    required this.viewModel,
  });

  final HabitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          AnalyticsSummaryCard(
            title: 'Weekly Summary (Last 7 Days)',
            summary: viewModel.weeklySummary,
          ),
          AnalyticsSummaryCard(
            title: 'Monthly Summary',
            summary: viewModel.monthlySummary,
          ),
          Card(
            child: ListTile(
              title: const Text('Current Streak'),
              subtitle: Text('${viewModel.streakCount} day(s)'),
              leading: const Icon(Icons.local_fire_department_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
