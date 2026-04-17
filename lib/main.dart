import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const DailyTrackrApp());
}

class DailyTrackrApp extends StatelessWidget {
  const DailyTrackrApp({super.key, this.storage});

  final TaskStorage? storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyTrackr',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: HabitTrackerPage(
        storage: storage ?? SharedPreferencesTaskStorage(),
      ),
    );
  }
}

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key, required this.storage});

  final TaskStorage storage;

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await widget.storage.loadTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final updated = [..._tasks, Task(title: title, isCompleted: false)];
    await widget.storage.saveTasks(updated);
    if (!mounted) return;
    setState(() {
      _tasks = updated;
      _taskController.clear();
    });
  }

  Future<void> _toggleTask(int index, bool? isCompleted) async {
    if (isCompleted == null) {
      return;
    }

    final updated = [..._tasks];
    updated[index] = updated[index].copyWith(isCompleted: isCompleted);
    await widget.storage.saveTasks(updated);
    if (!mounted) return;
    setState(() {
      _tasks = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DailyTrackr')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('taskInput'),
                          controller: _taskController,
                          decoration: const InputDecoration(
                            labelText: 'Add daily task',
                          ),
                          onSubmitted: (_) => _addTask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: const Key('addTaskButton'),
                        onPressed: _addTask,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _tasks.isEmpty
                        ? const Center(
                            child: Text('No tasks yet. Add one to get started.'),
                          )
                        : ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return CheckboxListTile(
                                key: Key('taskTile_$index'),
                                value: task.isCompleted,
                                title: Text(task.title),
                                onChanged: (value) => _toggleTask(index, value),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class Task {
  const Task({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;

  Task copyWith({String? title, bool? isCompleted}) {
    return Task(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

abstract class TaskStorage {
  Future<List<Task>> loadTasks();

  Future<void> saveTasks(List<Task> tasks);
}

class SharedPreferencesTaskStorage implements TaskStorage {
  static const _taskKey = 'daily_tasks_v1';

  @override
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_taskKey);
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_taskKey, encoded);
  }
}
