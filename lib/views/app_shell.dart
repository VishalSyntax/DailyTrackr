import 'package:flutter/material.dart';

import '../viewmodels/habit_view_model.dart';
import 'analytics_view.dart';
import 'calendar_view.dart';
import 'today_view.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.viewModel,
  });

  final HabitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        viewModel.refreshForNewDay();

        if (viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Habit Tracker')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Habit Tracker')),
          body: _buildBody(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: viewModel.selectedTabIndex,
            onTap: viewModel.setTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.today_outlined),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                label: 'Analytics',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (viewModel.selectedTabIndex) {
      case 0:
        return TodayView(viewModel: viewModel);
      case 1:
        return CalendarView(viewModel: viewModel);
      case 2:
        return AnalyticsView(viewModel: viewModel);
      default:
        return TodayView(viewModel: viewModel);
    }
  }
}
