class Ponto {
  final String id;
  final DateTime dataHora;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;

  Ponto({
    required this.id,
    required this.dataHora,
    this.fotoPath,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataHora': dataHora.toIso8601String(),
      'fotoPath': fotoPath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Ponto.fromMap(Map<String, dynamic> map) {
    return Ponto(
      id: map['id'],
      dataHora: DateTime.parse(map['dataHora']),
      fotoPath: map['fotoPath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
