import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> obterLocalizacaoAtual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Testar se os serviços de localização estão habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Os serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('As permissões de localização foram negadas.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('As permissões de localização estão permanentemente negadas.');
    }

    // Quando chegamos aqui, as permissões são concedidas e podemos
    // continuar acessando a localização do dispositivo.
    return await Geolocator.getCurrentPosition();
  }
}
