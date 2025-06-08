// screens/fridge/fridge_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/kuehlschrank.dart';
import 'package:haushalt_app/providers/fridge_provider.dart';
import 'package:intl/intl.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _lastCleanedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FridgeProvider>(context, listen: false).fetchFridgeStatus().then((_) {
        _populateFields();
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final fridge = Provider.of<FridgeProvider>(context, listen: false).fridge;
    if (fridge != null) {
      _contentController.text = fridge.inhaltBeschreibung;
      _notesController.text = fridge.hinweise;
      _lastCleanedDate = fridge.letzteReinigung;
    }
  }

  Future<void> _refreshStatus() async {
    await Provider.of<FridgeProvider>(context, listen: false).fetchFridgeStatus().then((_) {
      _populateFields();
    });
  }

  Future<void> _selectLastCleanedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastCleanedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _lastCleanedDate) {
      setState(() {
        _lastCleanedDate = picked;
      });
    }
  }

  void _updateFridgeStatus() {
    final fridgeProvider = Provider.of<FridgeProvider>(context, listen: false);
    final currentFridge = fridgeProvider.fridge;

    if (currentFridge == null) {
      _showErrorSnackbar('Kühlschrank-Instanz nicht gefunden. Bitte zuerst manuell im Backend erstellen (ID 1).');
      return;
    }

    final updatedFridge = Kuehlschrank(
      id: currentFridge.id,
      letzteReinigung: _lastCleanedDate,
      inhaltBeschreibung: _contentController.text,
      hinweise: _notesController.text,
    );

    fridgeProvider.updateFridgeStatus(updatedFridge).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kühlschrank-Status aktualisiert!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Aktualisieren: $error')),
      );
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FridgeProvider>(
        builder: (context, fridgeProvider, child) {
          if (fridgeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fridgeProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fehler: ${fridgeProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshStatus,
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }

          final fridge = fridgeProvider.fridge;

          if (fridge == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber, size: 80, color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(
                      'Keine Kühlschrank-Daten gefunden. Bitte stellen Sie sicher, dass eine Kühlschrank-Instanz (z.B. mit ID 1) im Django-Backend existiert.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshStatus,
                      child: const Text('Status erneut laden'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshStatus,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kühlschrank Details',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildStatusRow(
                            'Letzte Reinigung:',
                            fridge.letzteReinigung != null
                                ? DateFormat.yMd().format(fridge.letzteReinigung!)
                                : 'N/A',
                            Icons.cleaning_services,
                            Colors.blueAccent,
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            'Inhalt:',
                            fridge.inhaltBeschreibung.isNotEmpty
                                ? fridge.inhaltBeschreibung
                                : 'Keine Beschreibung',
                            Icons.kitchen,
                            Colors.orangeAccent,
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            'Hinweise:',
                            fridge.hinweise.isNotEmpty ? fridge.hinweise : 'Keine Hinweise',
                            Icons.info_outline,
                            Colors.grey[700]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Details bearbeiten:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Inhalt Beschreibung',
                      hintText: 'Z.B. Milch, Eier, Gemüse, Reste vom Vortag',
                      prefixIcon: Icon(Icons.shopping_basket),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Hinweise',
                      hintText: 'Z.B. Licht prüfen, Tür schließt nicht richtig',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Datum der letzten Reinigung',
                            hintText: 'Wählen Sie ein Datum',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.blueGrey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          child: Text(
                            _lastCleanedDate == null
                                ? 'Kein Datum ausgewählt'
                                : DateFormat.yMd().format(_lastCleanedDate!),
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectLastCleanedDate(context),
                      ),
                      if (_lastCleanedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _lastCleanedDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateFridgeStatus,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Status speichern'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.normal),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}