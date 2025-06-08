// providers/fridge_provider.dart
import 'package:flutter/material.dart';
import 'package:haushalt_app/models/kuehlschrank.dart';
import 'package:haushalt_app/models/lebensmittel.dart';
import 'package:haushalt_app/api/api_service.dart';

class FridgeProvider with ChangeNotifier {
  Kuehlschrank? _fridge;
  bool _isLoading = false;
  String? _errorMessage;

  Kuehlschrank? get fridge => _fridge;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();
  
void addLebensmittel(Lebensmittel lebensmittel) {
    _fridge?.lebensmittel.add(lebensmittel);
    notifyListeners();
  }
  Future<void> fetchFridgeStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fridges = await _apiService.getFridges();
      if (fridges.isNotEmpty) {
        // Assuming we primarily deal with one fridge for simplicity.
        _fridge = fridges.first;
      } else {
        _fridge = null; // No fridge found
      }
    } catch (e) {
      _errorMessage = 'Fehler beim Laden des Kühlschrank-Status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFridgeStatus(Kuehlschrank updatedFridge) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _fridge = await _apiService.updateFridge(updatedFridge);
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren des Kühlschrank-Status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}