// screens/tasks/task_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/haushaltsaufgabe.dart';
import 'package:haushalt_app/providers/task_provider.dart';
import 'package:haushalt_app/screens/tasks/task_detail_screen.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  Future<void> _refreshTasks() async {
    await Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fehler: ${taskProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshTasks,
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (taskProvider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Keine Aufgaben vorhanden!',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TaskDetailScreen(),
                        ),
                      );
                      _refreshTasks(); // Refresh list after adding a task
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Aufgabe hinzufügen'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTasks,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    leading: Checkbox(
                      value: task.erledigt,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          task.erledigt = newValue;
                          taskProvider.updateTask(task);
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      task.titel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.erledigt ? TextDecoration.lineThrough : null,
                        color: task.erledigt ? Colors.grey : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.beschreibung.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(task.beschreibung),
                          ),
                        if (task.faelligkeitsdatum != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Fällig: ${DateFormat.yMd().format(task.faelligkeitsdatum!)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: task.faelligkeitsdatum!.isBefore(DateTime.now()) && !task.erledigt
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Priorität: ${task.prioritaet}',
                            style: TextStyle(fontSize: 12, color: _getPriorityColor(task.prioritaet)),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(task: task),
                              ),
                            );
                            _refreshTasks(); // Refresh list after editing
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, task);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TaskDetailScreen(),
            ),
          );
          _refreshTasks(); // Refresh list after adding a task
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'HOCH':
        return Colors.red;
      case 'MITTEL':
        return Colors.orange;
      case 'NIEDRIG':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Haushaltsaufgabe task) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Aufgabe löschen?'),
          content: Text('Sind Sie sicher, dass Sie "${task.titel}" löschen möchten?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            ElevatedButton(
              child: const Text('Löschen'),
              onPressed: () {
                Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aufgabe erfolgreich gelöscht!')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Löschen der Aufgabe: $error')),
                  );
                });
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }
}