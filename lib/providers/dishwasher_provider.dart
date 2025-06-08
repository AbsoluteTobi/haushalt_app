import 'package:flutter/material.dart';
import 'package:haushalt_app/models/geschirrspueler.dart';
import 'package:haushalt_app/api/api_service.dart';

class DishwasherProvider with ChangeNotifier {
  Geschirrspueler? _dishwasher;
  bool _isLoading = false;
  String? _errorMessage;

  Geschirrspueler? get dishwasher => _dishwasher;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> fetchDishwasherStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final dishwashers = await _apiService.getDishwashers();
      if (dishwashers.isNotEmpty) {
        // Assuming we primarily deal with one dishwasher for simplicity.
        // In a real app, you might select by ID or handle multiple.
        _dishwasher = dishwashers.first;
      } else {
        _dishwasher = null; // No dishwasher found
      }
    } catch (e) {
      _errorMessage = 'Fehler beim Laden des Geschirrspüler-Status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDishwasherStatus(Geschirrspueler updatedDishwasher) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _dishwasher = await _apiService.updateDishwasher(updatedDishwasher);
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren des Geschirrspüler-Status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}