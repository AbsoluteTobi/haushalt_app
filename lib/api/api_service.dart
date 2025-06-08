// api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:haushalt_app/models/haushaltsaufgabe.dart';
import 'package:haushalt_app/models/geschirrspueler.dart';
import 'package:haushalt_app/models/kuehlschrank.dart';
import 'package:haushalt_app/models/waesche.dart';

class ApiService {
  // Base URL for your Django backend.
  // IMPORTANT: Use your actual Django backend IP/hostname if not running on localhost.
  // For Android emulator, '10.0.2.2' maps to your host machine's localhost.
  // For iOS simulator or real device, use your machine's local IP address (e.g., '192.168.1.X').
  static const String _baseUrl = 'http://192.168.178.22:8000/api'; // Example for Android Emulator

  // --- Haushaltsaufgaben (Household Tasks) ---
  Future<List<Haushaltsaufgabe>> getTasks() async {
    final response = await http.get(Uri.parse('$_baseUrl/haushaltsaufgaben/'));
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Haushaltsaufgabe.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<Haushaltsaufgabe> createTask(Haushaltsaufgabe task) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/haushaltsaufgaben/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Haushaltsaufgabe.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  Future<Haushaltsaufgabe> updateTask(Haushaltsaufgabe task) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/haushaltsaufgaben/${task.id}/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Haushaltsaufgabe.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/haushaltsaufgaben/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }

  // --- Geschirrspueler (Dishwasher) ---
  Future<List<Geschirrspueler>> getDishwashers() async {
    // Django REST Framework often returns a list, even for a single instance.
    // We'll assume there's usually only one dishwasher.
    final response = await http.get(Uri.parse('$_baseUrl/geschirrspueler/'));
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Geschirrspueler.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load dishwashers: ${response.statusCode}');
    }
  }

  Future<Geschirrspueler> updateDishwasher(Geschirrspueler dishwasher) async {
    // Assuming there's only one dishwasher with ID 1, or handle getting the correct ID
    final response = await http.put(
      Uri.parse('$_baseUrl/geschirrspueler/${dishwasher.id}/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(dishwasher.toJson()),
    );
    if (response.statusCode == 200) {
      return Geschirrspueler.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update dishwasher: ${response.statusCode}');
    }
  }

  // --- Kuehlschrank (Refrigerator) ---
  Future<List<Kuehlschrank>> getFridges() async {
    final response = await http.get(Uri.parse('$_baseUrl/kuehlschrank/'));
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Kuehlschrank.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load fridges: ${response.statusCode}');
    }
  }

  Future<Kuehlschrank> updateFridge(Kuehlschrank fridge) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/kuehlschrank/${fridge.id}/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(fridge.toJson()),
    );
    if (response.statusCode == 200) {
      return Kuehlschrank.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update fridge: ${response.statusCode}');
    }
  }

  // --- Waelte (Laundry) ---
  Future<List<Waelte>> getLaundryItems() async {
    final response = await http.get(Uri.parse('$_baseUrl/waesche/'));
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Waelte.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load laundry items: ${response.statusCode}');
    }
  }

  Future<Waelte> updateLaundry(Waelte laundry) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/waesche/${laundry.id}/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(laundry.toJson()),
    );
    if (response.statusCode == 200) {
      return Waelte.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update laundry: ${response.statusCode}');
    }
  }

  Future<Waelte> createLaundry(Waelte laundry) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/waesche/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(laundry.toJson()),
    );
    if (response.statusCode == 201) {
      return Waelte.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create laundry item: ${response.statusCode}');
    }
  }

  Future<void> deleteLaundry(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/waesche/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete laundry item: ${response.statusCode}');
    }
  }
}