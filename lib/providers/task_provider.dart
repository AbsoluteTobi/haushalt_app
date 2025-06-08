// providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:haushalt_app/models/haushaltsaufgabe.dart';
import 'package:haushalt_app/api/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Haushaltsaufgabe> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Haushaltsaufgabe> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tasks = await _apiService.getTasks();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Aufgaben: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Haushaltsaufgabe task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newTask = await _apiService.createTask(task);
      _tasks.add(newTask);
      // Optional: Sort tasks after adding
      _tasks.sort((a, b) {
        if (a.faelligkeitsdatum == null && b.faelligkeitsdatum == null) return 0;
        if (a.faelligkeitsdatum == null) return 1;
        if (b.faelligkeitsdatum == null) return -1;
        return a.faelligkeitsdatum!.compareTo(b.faelligkeitsdatum!);
      });
    } catch (e) {
      _errorMessage = 'Fehler beim Hinzufügen der Aufgabe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Haushaltsaufgabe task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedTask = await _apiService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      // Optional: Re-sort tasks after updating
      _tasks.sort((a, b) {
        if (a.faelligkeitsdatum == null && b.faelligkeitsdatum == null) return 0;
        if (a.faelligkeitsdatum == null) return 1;
        if (b.faelligkeitsdatum == null) return -1;
        return a.faelligkeitsdatum!.compareTo(b.faelligkeitsdatum!);
      });
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren der Aufgabe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
    } catch (e) {
      _errorMessage = 'Fehler beim Löschen der Aufgabe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}