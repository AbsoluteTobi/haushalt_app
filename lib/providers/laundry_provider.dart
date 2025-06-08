// providers/laundry_provider.dart
import 'package:flutter/material.dart';
import 'package:haushalt_app/models/waesche.dart';
import 'package:haushalt_app/api/api_service.dart';

class LaundryProvider with ChangeNotifier {
  List<Waelte> _laundryItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Waelte> get laundryItems => _laundryItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> fetchLaundryItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _laundryItems = await _apiService.getLaundryItems();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Wäsche-Elemente: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLaundryItem(Waelte laundry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newLaundry = await _apiService.createLaundry(laundry);
      _laundryItems.add(newLaundry);
    } catch (e) {
      _errorMessage = 'Fehler beim Hinzufügen des Wäsche-Elements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLaundryItem(Waelte laundry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedLaundry = await _apiService.updateLaundry(laundry);
      final index = _laundryItems.indexWhere((i) => i.id == updatedLaundry.id);
      if (index != -1) {
        _laundryItems[index] = updatedLaundry;
      }
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren des Wäsche-Elements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLaundryItem(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteLaundry(id);
      _laundryItems.removeWhere((item) => item.id == id);
    } catch (e) {
      _errorMessage = 'Fehler beim Löschen des Wäsche-Elements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}