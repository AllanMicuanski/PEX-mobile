import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/jornada_service.dart';
import '../config/theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/app_card.dart';

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
                    color: SizebayColors.vermelho.withValues(alpha: 0.1),
                    borderStrokeWidth: 2,
                    borderColor: SizebayColors.vermelho.withValues(alpha: 0.5),
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
                        color: SizebayColors.vermelho,
                        boxShadow: [
                          BoxShadow(
                            color: SizebayColors.vermelho.withValues(
                              alpha: 0.4,
                            ),
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
                          color: SizebayColors.azul,
                          boxShadow: [
                            BoxShadow(
                              color: SizebayColors.azul.withValues(alpha: 0.4),
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
    final scheme = Theme.of(context).colorScheme;
    final captionStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 12,
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppCard(
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
                    Text('Distância da empresa', style: captionStyle),
                    const SizedBox(height: 4),
                    Text(
                      '$_distanciaMetros m',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                StatusChip(
                  color: _dentroDoPermitido
                      ? SizebayColors.verde
                      : SizebayColors.laranja,
                  icon: _dentroDoPermitido ? Icons.check_circle : Icons.warning,
                  label: _dentroDoPermitido ? 'Dentro do raio' : 'Fora do raio',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raio permitido: ${Empresa.raioPermitidoMetros}m',
                    style: captionStyle,
                  ),
                  const SizedBox(height: 2),
                  Text('Empresa: ${Empresa.endereco}', style: captionStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
