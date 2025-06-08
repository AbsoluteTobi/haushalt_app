import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/kuehlschrank.dart';
import 'package:haushalt_app/models/lebensmittel.dart';
import 'package:haushalt_app/providers/fridge_provider.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  _FridgeScreenState createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  void _showAddLebensmittelDialog() {
    final nameController = TextEditingController();
    final mengeController = TextEditingController();
    final einheitController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Lebensmittel hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: mengeController,
              decoration: const InputDecoration(labelText: 'Menge'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: einheitController,
              decoration: const InputDecoration(labelText: 'Einheit'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final menge = double.tryParse(mengeController.text.trim()) ?? 0;
              final einheit = einheitController.text.trim();

              if (name.isNotEmpty && menge > 0 && einheit.isNotEmpty) {
                Provider.of<FridgeProvider>(context, listen: false).addLebensmittel(
                  Lebensmittel(name: name, menge: menge, einheit: einheit),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fridge = Provider.of<FridgeProvider>(context).fridge;


    return Scaffold(
      appBar: AppBar(title: const Text('Kühlschrank-Inhalt')),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: fridge!.lebensmittel.length + 1,
        itemBuilder: (context, index) {
          if (index == fridge?.lebensmittel.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Neues Lebensmittel hinzufügen'),
              onTap: _showAddLebensmittelDialog,
            );
          }

          final item = fridge?.lebensmittel[index];
          return CheckboxListTile(
            title: Text('${item?.name} (${item?.menge} ${item?.einheit})'),
            value: item?.einkaufen,
            onChanged: (value) {
              setState(() {
                item?.einkaufen = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}
