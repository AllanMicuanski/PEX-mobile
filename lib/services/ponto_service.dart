import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/ponto.dart';
import 'camera_service.dart';
import 'database_service.dart';
import 'location_service.dart';
import 'jornada_service.dart';

class Empresa {
  static const double latitude = -26.2746;
  static const double longitude = -48.8426;
}

class PontoService {
  final CameraService _cameraService = CameraService();
  final LocationService _locationService = LocationService();
  final DatabaseService _dbService = DatabaseService.instance;

  /// Valida se está dentro do raio de 500m da empresa
  Future<bool> validarGPS() async {
    try {
      final Position position = await _locationService.obterLocalizacaoAtual();
      final distancia = _calcularDistancia(
        Empresa.latitude,
        Empresa.longitude,
        position.latitude,
        position.longitude,
      );
      return distancia <= 500; // 500 metros
    } catch (_) {
      return false;
    }
  }

  /// Calcula distância entre dois pontos em metros (Haversine)
  double _calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // Raio da Terra em metros
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double degrees) => degrees * (pi / 180);

  /// Orquestra o fluxo de registro de ponto:
  /// 1. Captura Foto
  /// 2. Preview Foto
  /// 3. Captura Localização
  /// 4. Salva no Banco
  Future<void> registrarPontoCompleto({bool homeOffice = false}) async {
    // 1. Captura de Foto
    final String? fotoPath = await _cameraService.tirarFoto();
    if (fotoPath == null) {
      throw Exception('Operação cancelada: Foto não capturada.');
    }

    // 2. Captura de Localização (com validação pré-captura se não for home office)
    late Position position;
    if (!homeOffice) {
      position = await _locationService.obterLocalizacaoAtual();
    } else {
      position = Position(
        latitude: -26.2746,
        longitude: -48.8426,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }

    // 3. Criação do Objeto
    final agora = DateTime.now();
    final novoPonto = Ponto(
      id: agora.millisecondsSinceEpoch.toString(),
      dataHora: agora,
      tipo: JornadaService.detectarTipoPonto(agora),
      fotoPath: fotoPath,
      latitude: position.latitude,
      longitude: position.longitude,
      homeOffice: homeOffice,
    );

    // 4. Persistência
    await _dbService.inserirPonto(novoPonto);
  }

  /// Recupera todos os pontos ordenados por data
  Future<List<Ponto>> buscarHistoricoDePontos() async {
    return await _dbService.listarPontos();
  }
}
