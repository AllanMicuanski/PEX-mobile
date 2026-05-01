import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/jornada_service.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocationService _locationService = LocationService();
  late GoogleMapController mapController;

  Position? _usuarioPos;
  bool _carregando = true;
  int _distanciaMetros = 0;
  bool _dentroDoPermitido = false;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    try {
      final pos = await _locationService.obterLocalizacaoAtual();
      final distancia = await JornadaService.calcularDistancia(pos);
      final dentroDoRaio = await JornadaService.validarLocalizacao(pos);

      setState(() {
        _usuarioPos = pos;
        _distanciaMetros = distancia;
        _dentroDoPermitido = dentroDoRaio;
        _carregando = false;
      });

      // Move câmera para posição do usuário
      await Future.delayed(const Duration(milliseconds: 500));
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              Empresa.latitude - 0.005,
              Empresa.longitude - 0.005,
            ),
            northeast: LatLng(pos.latitude + 0.005, pos.longitude + 0.005),
          ),
          100,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar localização: $e')),
        );
      }
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Localização')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(Empresa.latitude, Empresa.longitude),
              zoom: 16,
            ),
            markers: {
              // Marcador da empresa
              Marker(
                markerId: const MarkerId('empresa'),
                position: LatLng(Empresa.latitude, Empresa.longitude),
                infoWindow: const InfoWindow(
                  title: 'Empresa',
                  snippet: 'R. Blumenau, 953',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
              // Marcador do usuário
              if (_usuarioPos != null)
                Marker(
                  markerId: const MarkerId('usuario'),
                  position: LatLng(
                    _usuarioPos!.latitude,
                    _usuarioPos!.longitude,
                  ),
                  infoWindow: const InfoWindow(title: 'Você está aqui'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
            },
            circles: {
              // Círculo de raio permitido
              Circle(
                circleId: const CircleId('raio'),
                center: LatLng(Empresa.latitude, Empresa.longitude),
                radius: Empresa.raioPermitidoMetros.toDouble(),
                fillColor: Colors.red.withValues(alpha: 0.1),
                strokeColor: Colors.red.withValues(alpha: 0.5),
                strokeWidth: 2,
              ),
            },
          ),
          // Info bottom
          Positioned(bottom: 0, left: 0, right: 0, child: _buildInfoBox()),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distância da Empresa',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_distanciaMetros m',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _dentroDoPermitido
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _dentroDoPermitido ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _dentroDoPermitido ? Icons.check_circle : Icons.warning,
                      color: _dentroDoPermitido ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _dentroDoPermitido ? 'Dentro do\nraio' : 'Fora do\nraio',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _dentroDoPermitido
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raio permitido: ${Empresa.raioPermitidoMetros}m',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Localização: ${Empresa.endereco}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
