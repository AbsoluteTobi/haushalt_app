// api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haushalt_app/models/haushaltsaufgabe.dart';
import 'package:haushalt_app/models/geschirrspueler.dart';
import 'package:haushalt_app/models/kuehlschrank.dart';
import 'package:haushalt_app/models/waesche.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.178.22:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // --- Haushaltsaufgaben (Household Tasks) ---
  Future<List<Haushaltsaufgabe>> getTasks() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/haushaltsaufgaben/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Haushaltsaufgabe.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<Haushaltsaufgabe> createTask(Haushaltsaufgabe task) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/haushaltsaufgaben/'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Haushaltsaufgabe.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  Future<Haushaltsaufgabe> updateTask(Haushaltsaufgabe task) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$_baseUrl/haushaltsaufgaben/${task.id}/'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Haushaltsaufgabe.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(int id) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/haushaltsaufgaben/$id/'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }

  // --- Geschirrspueler (Dishwasher) ---
  Future<List<Geschirrspueler>> getDishwashers() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/geschirrspueler/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Geschirrspueler.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load dishwashers: ${response.statusCode}');
    }
  }

  Future<Geschirrspueler> updateDishwasher(Geschirrspueler dishwasher) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$_baseUrl/geschirrspueler/${dishwasher.id}/'),
      headers: headers,
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
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/kuehlschrank/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Kuehlschrank.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load fridges: ${response.statusCode}');
    }
  }

  Future<Kuehlschrank> updateFridge(Kuehlschrank fridge) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$_baseUrl/kuehlschrank/${fridge.id}/'),
      headers: headers,
      body: jsonEncode(fridge.toJson()),
    );
    if (response.statusCode == 200) {
      return Kuehlschrank.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update fridge: ${response.statusCode}');
    }
  }

  // --- Waesche (Laundry) ---
  Future<List<Waelte>> getLaundryItems() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/waesche/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((model) => Waelte.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load laundry items: ${response.statusCode}');
    }
  }

  Future<Waelte> updateLaundry(Waelte laundry) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$_baseUrl/waesche/${laundry.id}/'),
      headers: headers,
      body: jsonEncode(laundry.toJson()),
    );
    if (response.statusCode == 200) {
      return Waelte.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update laundry: ${response.statusCode}');
    }
  }

  Future<Waelte> createLaundry(Waelte laundry) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/waesche/'),
      headers: headers,
      body: jsonEncode(laundry.toJson()),
    );
    if (response.statusCode == 201) {
      return Waelte.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create laundry item: ${response.statusCode}');
    }
  }

  Future<void> deleteLaundry(int id) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/waesche/$id/'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete laundry item: ${response.statusCode}');
    }
  }
}
