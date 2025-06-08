// screens/fridge/fridge_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/kuehlschrank.dart';
import 'package:haushalt_app/providers/fridge_provider.dart';
import 'package:intl/intl.dart';

class FridgeScreen extends StatefulWidget {

  const FridgeScreen({super.key, });

  @override
  _FridgeScreenState createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  void _showAddLebensmittelDialog() {
    // Hier öffnest du einen Dialog, um ein neues Lebensmittel hinzuzufügen.
  }

  @override
  Widget build(BuildContext context) {
    final fridge = widget.fridge;

    return Scaffold(
      appBar: AppBar(title: Text('Kühlschrank-Inhalt')),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: fridge.lebensmittel.length + 1, // +1 für den "Hinzufügen"-Button
        itemBuilder: (context, index) {
          if (index == fridge.lebensmittel.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Neues Lebensmittel hinzufügen'),
              onTap: _showAddLebensmittelDialog,
            );
          }

          final item = fridge.lebensmittel[index];
          return CheckboxListTile(
            title: Text('${item.name} (${item.menge} ${item.einheit})'),
            value: item.einkaufen,
            onChanged: (value) {
              setState(() {
                item.einkaufen = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}
