import 'lebensmittel.dart';

class Kuehlschrank {
  final String id;
  final String name;
  final List<Lebensmittel> lebensmittel;
  final String? hinweise;
  final DateTime? letzteReinigung;
  final DateTime? zuletztAktualisiert;

  Kuehlschrank({
    required this.id,
    required this.name,
    required this.lebensmittel,
    this.hinweise,
    this.letzteReinigung,
    this.zuletztAktualisiert,
  });

  factory Kuehlschrank.fromJson(Map<String, dynamic> json) {
    var lebensmittelList = (json['lebensmittel'] as List<dynamic>?)
        ?.map((e) => Lebensmittel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return Kuehlschrank(
      id: json['id'] as String,
      name: json['name'] as String,
      lebensmittel: lebensmittelList,
      hinweise: json['hinweise'] as String?,
      letzteReinigung: json['letzteReinigung'] != null
          ? DateTime.parse(json['letzteReinigung'] as String)
          : null,
      zuletztAktualisiert: json['zuletztAktualisiert'] != null
          ? DateTime.parse(json['zuletztAktualisiert'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lebensmittel': lebensmittel.map((e) => e.toJson()).toList(),
      'hinweise': hinweise,
      'letzteReinigung': letzteReinigung?.toIso8601String(),
      'zuletztAktualisiert': zuletztAktualisiert?.toIso8601String(),
    };
  }
}
