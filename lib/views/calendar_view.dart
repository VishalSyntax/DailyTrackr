import 'package:flutter/material.dart';

import '../viewmodels/habit_view_model.dart';
import '../widgets/habit_checkbox_tile.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({
    super.key,
    required this.viewModel,
  });

  final HabitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final completedHabits = viewModel.completedHabitsForSelectedDate;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Selected Date: ${_formatDate(viewModel.selectedCalendarDate)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              OutlinedButton(
                onPressed: () => _pickDate(context),
                child: const Text('Select Date'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed on selected date: ${completedHabits.length}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (completedHabits.isEmpty)
                    const Text('No completed habits for this date.')
                  else
                    ...completedHabits.map((habit) => Text('• ${habit.name}')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _showAddSpecialTaskDialog(context),
            icon: const Icon(Icons.add_task),
            label: const Text('Add Special Task For This Date'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: viewModel.calendarHabits.isEmpty
                ? const Center(child: Text('No habits found for this date.'))
                : ListView.builder(
                    itemCount: viewModel.calendarHabits.length,
                    itemBuilder: (context, index) {
                      final habit = viewModel.calendarHabits[index];
                      return HabitCheckboxTile(
                        habit: habit,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          viewModel.toggleCalendarHabit(index, value);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedCalendarDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    await viewModel.selectCalendarDate(selectedDate);
  }

  Future<void> _showAddSpecialTaskDialog(BuildContext context) async {
    var input = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Special Task'),
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

    await viewModel.addSpecialTaskForDate(
      name: result,
      date: viewModel.selectedCalendarDate,
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
