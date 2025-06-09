import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:haushalt_app/models/kuehlschrank.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  Kuehlschrank? kuehlschrank;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchKuehlschrank();
  }

  Future<void> fetchKuehlschrank() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.178.22:8000/api/kuehlschrank/1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Angenommen, Kuehlschrank hat eine fromJson Methode:
        print(response.body);
        setState(() {
          kuehlschrank = Kuehlschrank.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Fehler beim Laden: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Fehler: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Kühlschrank")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text("Kühlschrank")),
        body: Center(child: Text(error!)),
      );
    }

    if (kuehlschrank == null || kuehlschrank!.lebensmittel.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Kühlschrank")),
        body: Center(child: Text("Keine Lebensmittel gefunden.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Kühlschrank")),
      body: ListView.builder(
        itemCount: kuehlschrank!.lebensmittel.length,
        itemBuilder: (context, index) {
          final item = kuehlschrank!.lebensmittel[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('${item.menge} ${item.einheit}'),
          );
        },
      ),
    );
  }
}
