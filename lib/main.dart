import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/hive_storage_service.dart';
import 'viewmodels/habit_view_model.dart';
import 'views/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>(HiveStorageService.boxName);
  runApp(
    DailyTrackrApp(
      viewModel: HabitViewModel(
        storageService: HiveStorageService(box),
      ),
    ),
  );
}

class DailyTrackrApp extends StatefulWidget {
  const DailyTrackrApp({super.key, required this.viewModel});

  final HabitViewModel viewModel;

  @override
  State<DailyTrackrApp> createState() => _DailyTrackrAppState();
}

class _DailyTrackrAppState extends State<DailyTrackrApp> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: AppShell(viewModel: widget.viewModel),
    );
  }
}
