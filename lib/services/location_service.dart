import 'package:geolocator/geolocator.dart';

class LocationService {
  static bool _initialized = false;

  /// Inicializa o serviço de localização (safe initialization)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Requisita permissão de localização na inicialização
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      _initialized = true;
    } catch (e) {
      // Falha silenciosa na inicialização
      print('locationService.initialize() warning: $e');
    }
  }

  /// Obtém a localização atual ou lança uma exceção com a causa do erro.
  Future<Position> obterLocalizacaoAtual() async {
    // Garante inicialização antes de tentar obter a localização
    await initialize();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS desativado. Por favor, habilite a localização.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. Altere nas configurações.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } catch (e) {
      throw Exception(
        'Erro ao obter GPS (timeout ou indisponível). Tente novamente em uma área aberta. Erro: $e',
      );
    }
  }
}
