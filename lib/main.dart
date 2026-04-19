import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/local_storage_service.dart';

void main() {
  runApp(const DailyTrackrApp());
}

class DailyTrackrApp extends StatelessWidget {
  const DailyTrackrApp({super.key, this.storageService});

  final LocalStorageService? storageService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: HomeScreen(
        storageService: storageService ?? LocalStorageService(),
      ),
    );
  }
}
