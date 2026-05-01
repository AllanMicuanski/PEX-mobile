import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/jornada_service.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late MapController _mapController;
  Position? _usuarioPos;
  bool _carregando = true;
  int _distanciaMetros = 0;
  bool _dentroDoPermitido = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Calcula distância
      final distancia = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        Empresa.latitude,
        Empresa.longitude,
      ).toInt();

      final dentroDoRaio = distancia <= Empresa.raioPermitidoMetros;

      setState(() {
        _usuarioPos = pos;
        _distanciaMetros = distancia;
        _dentroDoPermitido = dentroDoRaio;
        _carregando = false;
      });

      // Move câmera para posição do usuário
      _mapController.move(LatLng(Empresa.latitude, Empresa.longitude), 16);
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(Empresa.latitude, Empresa.longitude),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pex_mob',
              ),
              // Círculo de raio permitido
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(Empresa.latitude, Empresa.longitude),
                    radius: Empresa.raioPermitidoMetros.toDouble(),
                    useRadiusInMeter: true,
                    color: Colors.red.withValues(alpha: 0.1),
                    borderStrokeWidth: 2,
                    borderColor: Colors.red.withValues(alpha: 0.5),
                  ),
                ],
              ),
              // Marcadores
              MarkerLayer(
                markers: [
                  // Marcador da empresa (vermelho)
                  Marker(
                    point: LatLng(Empresa.latitude, Empresa.longitude),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // Marcador do usuário (azul)
                  if (_usuarioPos != null)
                    Marker(
                      point: LatLng(
                        _usuarioPos!.latitude,
                        _usuarioPos!.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Info box
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
