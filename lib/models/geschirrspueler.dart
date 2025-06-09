
class Geschirrspueler {
  final int? id;
  final String status; // AN, AUS
  final DateTime? letzterStart;
  final DateTime? zuletztAktualisiert;

  Geschirrspueler({
    this.id,
    required this.status,
    this.letzterStart,
    this.zuletztAktualisiert,
  });

  factory Geschirrspueler.fromJson(Map<String, dynamic> json) {
    return Geschirrspueler(
      id: json['id'],
      status: json['status'] ?? 'AUS',
      letzterStart: json['letzter_start'] != null
          ? DateTime.tryParse(json['letzter_start'])
          : null,
      zuletztAktualisiert: json['zuletzt_aktualisiert'] != null
          ? DateTime.tryParse(json['zuletzt_aktualisiert'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'letzter_start': letzterStart?.toIso8601String(), // ISO 8601 for datetime
    };
  }
}