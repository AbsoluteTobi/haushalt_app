// models/lebensmittel.dart
class Lebensmittel {
  final String name;
  final double menge;
  final String einheit;
  bool einkaufen;

  Lebensmittel({
    required this.name,
    required this.menge,
    required this.einheit,
    this.einkaufen = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'menge': menge,
    'einheit': einheit,
    'einkaufen': einkaufen,
  };

  factory Lebensmittel.fromJson(Map<String, dynamic> json) => Lebensmittel(
    name: json['name'],
    menge: (json['menge'] as num).toDouble(),
    einheit: json['einheit'],
    einkaufen: json['einkaufen'] ?? false,
  );
}