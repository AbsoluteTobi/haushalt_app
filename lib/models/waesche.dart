// models/waesche.dart
import 'package:intl/intl.dart';

class Waelte {
  final int? id;
  final String waescheTyp;
  final String status; // SAUBER, SCHMUTZIG, IN_WASCHMASCHINE, etc.
  final DateTime? zuletztGewaschen;
  final DateTime? zuletztAktualisiert;

  Waelte({
    this.id,
    this.waescheTyp = '',
    required this.status,
    this.zuletztGewaschen,
    this.zuletztAktualisiert,
  });

  factory Waelte.fromJson(Map<String, dynamic> json) {
    return Waelte(
      id: json['id'],
      waescheTyp: json['waesche_typ'] ?? '',
      status: json['status'] ?? 'SCHMUTZIG',
      zuletztGewaschen: json['zuletzt_gewaschen'] != null
          ? DateTime.tryParse(json['zuletzt_gewaschen'])
          : null,
      zuletztAktualisiert: json['zuletzt_aktualisiert'] != null
          ? DateTime.tryParse(json['zuletzt_aktualisiert'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'waesche_typ': waescheTyp,
      'status': status,
      'zuletzt_gewaschen': zuletztGewaschen?.toIso8601String(),
    };
  }
}