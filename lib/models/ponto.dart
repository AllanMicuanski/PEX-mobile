enum TipoPonto { entrada, almoco, retorno, saida }

class Ponto {
  final String id;
  final DateTime dataHora;
  final TipoPonto tipo;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;
  final bool homeOffice;

  Ponto({
    required this.id,
    required this.dataHora,
    required this.tipo,
    this.fotoPath,
    this.latitude,
    this.longitude,
    this.homeOffice = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataHora': dataHora.toIso8601String(),
      'tipo': tipo.toString().split('.').last,
      'fotoPath': fotoPath,
      'latitude': latitude,
      'longitude': longitude,
      'homeOffice': homeOffice ? 1 : 0,
    };
  }

  factory Ponto.fromMap(Map<String, dynamic> map) {
    return Ponto(
      id: map['id'],
      dataHora: DateTime.parse(map['dataHora']),
      tipo: TipoPonto.values.firstWhere(
        (e) => e.toString().split('.').last == map['tipo'],
        orElse: () => TipoPonto.entrada,
      ),
      fotoPath: map['fotoPath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      homeOffice: (map['homeOffice'] ?? 0) == 1,
    );
  }
}
