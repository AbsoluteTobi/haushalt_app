// screens/tasks/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/haushaltsaufgabe.dart';
import 'package:haushalt_app/providers/task_provider.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Haushaltsaufgabe? task; // Null for new task, not null for editing

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  DateTime? _dueDate;
  String _priority = 'MITTEL'; // Default priority

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.titel ?? '');
    _descriptionController = TextEditingController(text: widget.task?.beschreibung ?? '');
    _isCompleted = widget.task?.erledigt ?? false;
    _dueDate = widget.task?.faelligkeitsdatum;
    _priority = widget.task?.prioritaet ?? 'MITTEL';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final newOrUpdatedTask = Haushaltsaufgabe(
        id: widget.task?.id, // ID is null for new tasks
        titel: _titleController.text,
        beschreibung: _descriptionController.text,
        erledigt: _isCompleted,
        faelligkeitsdatum: _dueDate,
        prioritaet: _priority,
      );

      if (widget.task == null) {
        // Add new task
        taskProvider.addTask(newOrUpdatedTask).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aufgabe erfolgreich hinzugefügt!')),
          );
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Hinzufügen der Aufgabe: $error')),
          );
        });
      } else {
        // Update existing task
        taskProvider.updateTask(newOrUpdatedTask).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aufgabe erfolgreich aktualisiert!')),
          );
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Aktualisieren der Aufgabe: $error')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'Geben Sie den Titel der Aufgabe ein',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie einen Titel ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: 'Optionale Beschreibung der Aufgabe',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Erledigt'),
                value: _isCompleted,
                onChanged: (bool value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fälligkeitsdatum',
                        hintText: 'Wählen Sie ein Datum',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.blueGrey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Text(
                        _dueDate == null
                            ? 'Kein Datum ausgewählt'
                            : DateFormat.yMd().format(_dueDate!),
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDueDate(context),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Priorität',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _priority,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _priority = newValue!;
                      });
                    },
                    items: <String>['HOCH', 'MITTEL', 'NIEDRIG']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(widget.task == null ? 'Aufgabe hinzufügen' : 'Aufgabe speichern'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}