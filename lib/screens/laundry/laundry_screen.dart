// screens/laundry/laundry_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haushalt_app/models/waesche.dart';
import 'package:haushalt_app/providers/laundry_provider.dart';
import 'package:intl/intl.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaundryProvider>(context, listen: false).fetchLaundryItems();
    });
  }

  Future<void> _refreshLaundry() async {
    await Provider.of<LaundryProvider>(context, listen: false).fetchLaundryItems();
  }

  // Options for laundry status as defined in Django model
  final List<String> _statusOptions = [
    'SAUBER', 'SCHMUTZIG', 'IN_WASCHMASCHINE', 'FERTIG_WASCHMASCHINE', 'IM_TROCKNER', 'FERTIG_TROCKNER'
  ];

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'SAUBER': return 'Sauber';
      case 'SCHMUTZIG': return 'Schmutzig';
      case 'IN_WASCHMASCHINE': return 'In Waschmaschine';
      case 'FERTIG_WASCHMASCHINE': return 'Waschmaschine fertig';
      case 'IM_TROCKNER': return 'Im Trockner';
      case 'FERTIG_TROCKNER': return 'Trockner fertig';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'SAUBER': return Icons.check_circle_outline;
      case 'SCHMUTZIG': return Icons.dirty_lens;
      case 'IN_WASCHMASCHINE': return Icons.wash;
      case 'FERTIG_WASCHMASCHINE': return Icons.local_laundry_service;
      case 'IM_TROCKNER': return Icons.dry_cleaning;
      case 'FERTIG_TROCKNER': return Icons.heat_pump;
      default: return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SAUBER': return Colors.green;
      case 'SCHMUTZIG': return Colors.brown;
      case 'IN_WASCHMASCHINE': return Colors.blueAccent;
      case 'FERTIG_WASCHMASCHINE': return Colors.lightBlue;
      case 'IM_TROCKNER': return Colors.orange;
      case 'FERTIG_TROCKNER': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }


  void _showAddEditLaundryDialog({Waelte? laundryItem}) {
    final TextEditingController typeController = TextEditingController(text: laundryItem?.waescheTyp ?? '');
    String currentStatus = laundryItem?.status ?? 'SCHMUTZIG';
    DateTime? lastWashedDate = laundryItem?.zuletztGewaschen;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(laundryItem == null ? 'Neues Wäsche-Element' : 'Wäsche bearbeiten'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Wäsche-Typ (optional)', hintText: 'z.B. Handtücher, Buntwäsche'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(_getDisplayStatus(status)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            currentStatus = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Zuletzt gewaschen',
                            ),
                            child: Text(
                              lastWashedDate == null
                                  ? 'Kein Datum ausgewählt'
                                  : DateFormat.yMd().format(lastWashedDate!),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: lastWashedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != lastWashedDate) {
                              setState(() {
                                lastWashedDate = picked;
                              });
                            }
                          },
                        ),
                        if (lastWashedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                lastWashedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newOrUpdatedItem = Waelte(
                      id: laundryItem?.id,
                      waescheTyp: typeController.text,
                      status: currentStatus,
                      zuletztGewaschen: lastWashedDate,
                    );
                    if (laundryItem == null) {
                      Provider.of<LaundryProvider>(context, listen: false).addLaundryItem(newOrUpdatedItem);
                    } else {
                      Provider.of<LaundryProvider>(context, listen: false).updateLaundryItem(newOrUpdatedItem);
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(laundryItem == null ? 'Hinzufügen' : 'Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Waelte item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Wäsche-Element löschen?'),
          content: Text('Sind Sie sicher, dass Sie "${item.waescheTyp.isEmpty ? "dieses Wäsche-Element" : item.waescheTyp}" löschen möchten?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Löschen'),
              onPressed: () {
                Provider.of<LaundryProvider>(context, listen: false).deleteLaundryItem(item.id!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wäsche-Element erfolgreich gelöscht!')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Löschen: $error')),
                  );
                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LaundryProvider>(
        builder: (context, laundryProvider, child) {
          if (laundryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (laundryProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fehler: ${laundryProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshLaundry,
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (laundryProvider.laundryItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_laundry_service_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Keine Wäsche-Elemente vorhanden!',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditLaundryDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Wäsche hinzufügen'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshLaundry,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: laundryProvider.laundryItems.length,
              itemBuilder: (context, index) {
                final item = laundryProvider.laundryItems[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(item.status),
                      child: Icon(_getStatusIcon(item.status), color: Colors.white),
                    ),
                    title: Text(
                      item.waescheTyp.isNotEmpty ? item.waescheTyp : 'Unbekannter Typ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${_getDisplayStatus(item.status)}'),
                        if (item.zuletztGewaschen != null)
                          Text('Zuletzt gewaschen: ${DateFormat.yMd().format(item.zuletztGewaschen!)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showAddEditLaundryDialog(laundryItem: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmationDialog(context, item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditLaundryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}