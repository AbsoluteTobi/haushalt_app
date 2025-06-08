// models/haushaltsaufgabe.dart
import 'package:intl/intl.dart';

class Haushaltsaufgabe {
  final int? id;
  final String titel;
  final String beschreibung;
  bool erledigt;
  final DateTime? faelligkeitsdatum;
  final String prioritaet; // HOCH, MITTEL, NIEDRIG
  final DateTime? zuletztAktualisiert;
  final DateTime? erstelltAm;

  Haushaltsaufgabe({
    this.id,
    required this.titel,
    this.beschreibung = '',
    this.erledigt = false,
    this.faelligkeitsdatum,
    this.prioritaet = 'MITTEL',
    this.zuletztAktualisiert,
    this.erstelltAm,
  });

  factory Haushaltsaufgabe.fromJson(Map<String, dynamic> json) {
    return Haushaltsaufgabe(
      id: json['id'],
      titel: json['titel'],
      beschreibung: json['beschreibung'] ?? '',
      erledigt: json['erledigt'] ?? false,
      faelligkeitsdatum: json['faelligkeitsdatum'] != null
          ? DateTime.tryParse(json['faelligkeitsdatum'])
          : null,
      prioritaet: json['prioritaet'] ?? 'MITTEL',
      zuletztAktualisiert: json['zuletzt_aktualisiert'] != null
          ? DateTime.tryParse(json['zuletzt_aktualisiert'])
          : null,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.tryParse(json['erstellt_am'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'id': id,
      'titel': titel,
      'beschreibung': beschreibung,
      'erledigt': erledigt,
      'faelligkeitsdatum': faelligkeitsdatum != null
          ? formatter.format(faelligkeitsdatum!)
          : null,
      'prioritaet': prioritaet,
      // 'zuletzt_aktualisiert' and 'erstellt_am' are often set by Django auto_now/auto_now_add
    };
  }
}