// models/kuehlschrank.dart
import 'package:intl/intl.dart';
import 'lebensmittel.dart';


class Kuehlschrank {
  final int? id;
  final DateTime? letzteReinigung;
  final String inhaltBeschreibung;
  final String hinweise;
  final DateTime? zuletztAktualisiert;
  final List<Lebensmittel> lebensmittel;

  Kuehlschrank({
    this.id,
    this.letzteReinigung,
    this.inhaltBeschreibung = '',
    this.hinweise = '',
    this.zuletztAktualisiert,
    List<Lebensmittel>? lebensmittel, // optional
}) : lebensmittel = lebensmittel ?? [];


  factory Kuehlschrank.fromJson(Map<String, dynamic> json) {
    return Kuehlschrank(
      id: json['id'],
      letzteReinigung: json['letzte_reinigung'] != null
          ? DateTime.tryParse(json['letzte_reinigung'])
          : null,
      inhaltBeschreibung: json['inhalt_beschreibung'] ?? '',
      hinweise: json['hinweise'] ?? '',
      zuletztAktualisiert: json['zuletzt_aktualisiert'] != null
          ? DateTime.tryParse(json['zuletzt_aktualisiert'])
          : null,
      lebensmittel: (json['lebensmittel'] as List<dynamic>? ?? [])
          .map((item) => Lebensmittel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'id': id,
      'letzte_reinigung':
          letzteReinigung != null ? formatter.format(letzteReinigung!) : null,
      'inhalt_beschreibung': inhaltBeschreibung,
      'hinweise': hinweise,
      'lebensmittel': lebensmittel.map((e) => e.toJson()).toList(),
    };
  }
}
