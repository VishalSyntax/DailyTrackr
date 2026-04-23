import 'package:flutter/material.dart';

import '../viewmodels/habit_view_model.dart';
import '../widgets/habit_checkbox_tile.dart';
import '../widgets/progress_card.dart';

class TodayView extends StatelessWidget {
  const TodayView({
    super.key,
    required this.viewModel,
  });

  final HabitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What did you complete today?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ProgressCard(
            completedCount: viewModel.completedTodayCount,
            totalCount: viewModel.todayHabits.length,
            progress: viewModel.todayProgress,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _showAddCustomHabitDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Habit'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAddSpecialTaskDialog(
                  context,
                  initialDate: viewModel.today,
                ),
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Add Special Task'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: viewModel.todayHabits.isEmpty
                ? const Center(child: Text('No habits available for today.'))
                : ListView.builder(
                    itemCount: viewModel.todayHabits.length,
                    itemBuilder: (context, index) {
                      final habit = viewModel.todayHabits[index];
                      return HabitCheckboxTile(
                        habit: habit,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          viewModel.toggleTodayHabit(index, value);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCustomHabitDialog(BuildContext context) async {
    var input = '';
    final viewModel = this.viewModel;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Custom Habit'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Habit name'),
            onChanged: (value) => input = value.trim(),
            onSubmitted: (_) => Navigator.of(dialogContext).pop(input),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(input),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    await viewModel.addCustomHabit(result);
  }

  Future<void> _showAddSpecialTaskDialog(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    var input = '';
    final viewModel = this.viewModel;

    DateTime selectedDate = initialDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 1),
      lastDate: DateTime(initialDate.year + 1),
    );

    if (!context.mounted) {
      return;
    }

    if (picked != null) {
      selectedDate = DateTime(picked.year, picked.month, picked.day);
    }

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Special Task'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Task name'),
            onChanged: (value) => input = value.trim(),
            onSubmitted: (_) => Navigator.of(dialogContext).pop(input),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(input),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    await viewModel.addSpecialTaskForDate(name: result, date: selectedDate);
  }
}
