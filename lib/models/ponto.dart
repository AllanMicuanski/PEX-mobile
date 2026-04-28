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
}
