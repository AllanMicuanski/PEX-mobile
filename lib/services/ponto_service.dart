import 'package:geolocator/geolocator.dart';
import '../models/ponto.dart';
import 'camera_service.dart';
import 'database_service.dart';
import 'location_service.dart';
import 'jornada_service.dart';

class PontoService {
  final CameraService _cameraService = CameraService();
  final LocationService _locationService = LocationService();
  final DatabaseService _dbService = DatabaseService.instance;

  /// Orquestra o fluxo de registro de ponto:
  /// 1. Captura Foto
  /// 2. Captura Localização
  /// 3. Salva no Banco
  Future<void> registrarPontoCompleto() async {
    // 1. Captura de Foto
    final String? fotoPath = await _cameraService.tirarFoto();
    if (fotoPath == null) {
      throw Exception('Operação cancelada: Foto não capturada.');
    }

    // 2. Captura de Localização
    final Position position = await _locationService.obterLocalizacaoAtual();

    // 3. Criação do Objeto
    final agora = DateTime.now();
    final novoPonto = Ponto(
      id: agora.millisecondsSinceEpoch.toString(),
      dataHora: agora,
      tipo: JornadaService.detectarTipoPonto(agora),
      fotoPath: fotoPath,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // 4. Persistência
    await _dbService.inserirPonto(novoPonto);
  }

  /// Recupera todos os pontos ordenados por data
  Future<List<Ponto>> buscarHistoricoDePontos() async {
    return await _dbService.listarPontos();
  }
}
