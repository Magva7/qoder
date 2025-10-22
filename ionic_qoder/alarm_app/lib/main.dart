import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TaskManagerPage(title: 'Мои задачи'),
    );
  }
}

class Task {
  final String name;
  final String location;
  final DateTime? reminder;

  Task({required this.name, required this.location, this.reminder});
}

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key, required this.title});

  final String title;

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  List<Task> homeTasks = [];
  List<Task> outdoorTasks = [];
  
  final TextEditingController _taskNameController = TextEditingController();
  DateTime? _selectedReminder;
  
  String _selectedLocation = 'Дома';
  
  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedReminder = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  
  void _showAddTaskDialog() {
    _taskNameController.clear();
    _selectedReminder = null;
    _selectedLocation = 'Дома';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Добавить задачу'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskNameController,
                      decoration: const InputDecoration(
                        labelText: 'Название задачи',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Где выполнить',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Дома', child: Text('Дома')),
                        DropdownMenuItem(value: 'На улице', child: Text('На улице')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Напоминание (опционально)'),
                      subtitle: Text(
                        _selectedReminder == null
                            ? 'Не выбрано'
                            : '${_selectedReminder!.day}.${_selectedReminder!.month}.${_selectedReminder!.year} ${_selectedReminder!.hour}:${_selectedReminder!.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _selectDateTime,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskNameController.text.isNotEmpty) {
                      _addTask();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _addTask() {
    setState(() {
      final newTask = Task(
        name: _taskNameController.text,
        location: _selectedLocation,
        reminder: _selectedReminder,
      );
      
      if (_selectedLocation == 'Дома') {
        homeTasks.add(newTask);
      } else {
        outdoorTasks.add(newTask);
      }
      
      // If a reminder is set, create an alarm
      if (_selectedReminder != null) {
        _setAlarmForTask(_taskNameController.text, _selectedReminder!);
      }
    });
  }
  
  void _setAlarmForTask(String taskName, DateTime reminder) {
    // Create an Android intent to set an alarm
    final intent = AndroidIntent(
      action: 'android.intent.action.SET_ALARM',
      arguments: {
        'android.intent.extra.alarm.HOUR': reminder.hour,
        'android.intent.extra.alarm.MINUTES': reminder.minute,
        'android.intent.extra.alarm.MESSAGE': taskName,
      },
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    
    intent.launch();
  }
  
  void _removeTask(Task task, String location) {
    setState(() {
      if (location == 'Дома') {
        homeTasks.remove(task);
      } else {
        outdoorTasks.remove(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дома column
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Дома',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: homeTasks.isEmpty
                          ? const Center(child: Text('Нет задач'))
                          : ListView.builder(
                              itemCount: homeTasks.length,
                              itemBuilder: (context, index) {
                                final task = homeTasks[index];
                                return ListTile(
                                  title: Text(task.name),
                                  subtitle: task.reminder != null
                                      ? Text(
                                          'Напоминание: ${task.reminder!.day}.${task.reminder!.month}.${task.reminder!.year} ${task.reminder!.hour}:${task.reminder!.minute.toString().padLeft(2, '0')}')
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeTask(task, 'Дома'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // На улице column
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'На улице',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: outdoorTasks.isEmpty
                          ? const Center(child: Text('Нет задач'))
                          : ListView.builder(
                              itemCount: outdoorTasks.length,
                              itemBuilder: (context, index) {
                                final task = outdoorTasks[index];
                                return ListTile(
                                  title: Text(task.name),
                                  subtitle: task.reminder != null
                                      ? Text(
                                          'Напоминание: ${task.reminder!.day}.${task.reminder!.month}.${task.reminder!.year} ${task.reminder!.hour}:${task.reminder!.minute.toString().padLeft(2, '0')}')
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeTask(task, 'На улице'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Добавить задачу',
      ),
    );
  }
}