class Lebensmittel {
  final String name;
  final double menge;
  final String einheit;

  Lebensmittel({
    required this.name,
    required this.menge,
    required this.einheit,
  });

  factory Lebensmittel.fromJson(Map<String, dynamic> json) {
    return Lebensmittel(
      name: json['name'] as String,
      menge: (json['menge'] as num).toDouble(),
      einheit: json['einheit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'menge': menge,
      'einheit': einheit,
    };
  }
}
