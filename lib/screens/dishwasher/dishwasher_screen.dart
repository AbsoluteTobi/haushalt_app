// screens/dishwasher/dishwasher_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/geschirrspueler.dart';
import 'package:haushalt_app/providers/dishwasher_provider.dart';
import 'package:intl/intl.dart';

class DishwasherScreen extends StatefulWidget {
  const DishwasherScreen({super.key});

  @override
  State<DishwasherScreen> createState() => _DishwasherScreenState();
}

class _DishwasherScreenState extends State<DishwasherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DishwasherProvider>(context, listen: false).fetchDishwasherStatus();
    });
  }

  Future<void> _refreshStatus() async {
    await Provider.of<DishwasherProvider>(context, listen: false).fetchDishwasherStatus();
  }

  void _updateStatus(String newStatus, String newFillLevel, DateTime? lastRun) {
    final dishwasherProvider = Provider.of<DishwasherProvider>(context, listen: false);
    final currentDishwasher = dishwasherProvider.dishwasher;

    if (currentDishwasher == null) {
      // If no dishwasher exists (first run), you might need to create it first.
      // For simplicity, we'll assume one exists with ID 1 and update it.
      // In a real app, you'd manage creation or ensure a single instance.
      _showErrorSnackbar('Geschirrspüler-Instanz nicht gefunden. Bitte zuerst manuell im Backend erstellen (ID 1).');
      return;
    }

    final updatedDishwasher = Geschirrspueler(
      id: currentDishwasher.id,
      status: newStatus,
      fuellstand: newFillLevel,
      letzterStart: lastRun ?? currentDishwasher.letzterStart,
    );

    dishwasherProvider.updateDishwasherStatus(updatedDishwasher).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geschirrspüler-Status aktualisiert!')),
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
      body: Consumer<DishwasherProvider>(
        builder: (context, dishwasherProvider, child) {
          if (dishwasherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (dishwasherProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fehler: ${dishwasherProvider.errorMessage}',
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

          final dishwasher = dishwasherProvider.dishwasher;

          if (dishwasher == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber, size: 80, color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(
                      'Keine Geschirrspüler-Daten gefunden. Bitte stellen Sie sicher, dass eine Geschirrspüler-Instanz (z.B. mit ID 1) im Django-Backend existiert.',
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
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
                          'Geschirrspüler Status',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        _buildStatusRow(
                          'Status:',
                          dishwasher.status == 'AN' ? 'An' : 'Aus',
                          Icons.power_settings_new,
                          dishwasher.status == 'AN' ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 10),
                        _buildStatusRow(
                          'Füllstand:',
                          _getFillLevelText(dishwasher.fuellstand),
                          _getFillLevelIcon(dishwasher.fuellstand),
                          _getFillLevelColor(dishwasher.fuellstand),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusRow(
                          'Letzter Start:',
                          dishwasher.letzterStart != null
                              ? DateFormat('dd.MM.yyyy HH:mm').format(dishwasher.letzterStart!)
                              : 'N/A',
                          Icons.schedule,
                          Colors.grey[700]!,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Aktionen:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 15.0,
                  runSpacing: 15.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      'Starten & Leeren',
                      Icons.play_arrow,
                      () => _updateStatus('AN', 'LEER', DateTime.now()),
                      Colors.green[600]!,
                    ),
                    _buildActionButton(
                      context,
                      'Ausschalten',
                      Icons.power_off,
                      () => _updateStatus('AUS', dishwasher.fuellstand, dishwasher.letzterStart),
                      Colors.deepOrange,
                    ),
                    _buildActionButton(
                      context,
                      'Als Voll markieren',
                      Icons.disc_full,
                      () => _updateStatus(dishwasher.status, 'VOLL', dishwasher.letzterStart),
                      Colors.blueAccent,
                    ),
                    _buildActionButton(
                      context,
                      'Als Halb voll markieren',
                      Icons.hourglass_bottom,
                      () => _updateStatus(dishwasher.status, 'HALB_VOLL', dishwasher.letzterStart),
                      Colors.amber,
                    ),
                    _buildActionButton(
                      context,
                      'Als Leer markieren',
                      Icons.delete_sweep,
                      () => _updateStatus(dishwasher.status, 'LEER', dishwasher.letzterStart),
                      Colors.lightBlue,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 15),
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String text, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        minimumSize: const Size(160, 50), // Ensure buttons have a minimum size
      ),
    );
  }

  String _getFillLevelText(String fuellstand) {
    switch (fuellstand) {
      case 'VOLL': return 'Voll';
      case 'LEER': return 'Leer';
      case 'HALB_VOLL': return 'Halb Voll';
      default: return 'Unbekannt';
    }
  }

  IconData _getFillLevelIcon(String fuellstand) {
    switch (fuellstand) {
      case 'VOLL': return Icons.circle;
      case 'LEER': return Icons.circle_outlined;
      case 'HALB_VOLL': return Icons.star_half; // This icon might not exist, use a suitable alternative
      default: return Icons.help_outline;
    }
  }

  Color _getFillLevelColor(String fuellstand) {
    switch (fuellstand) {
      case 'VOLL': return Colors.brown;
      case 'LEER': return Colors.grey;
      case 'HALB_VOLL': return Colors.amber;
      default: return Colors.grey;
    }
  }
}