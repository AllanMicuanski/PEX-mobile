import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ponto.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _cameraService = CameraService();
  final LocationService _locationService = LocationService();
  final DatabaseService _dbService = DatabaseService.instance;
  
  List<Ponto> _pontos = [];
  bool _isProcessing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  Future<void> _carregarPontos() async {
    setState(() => _isLoading = true);
    final pontos = await _dbService.listarPontos();
    setState(() {
      _pontos = pontos;
      _isLoading = false;
    });
  }

  Future<void> _baterPonto() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Obter Localização
      final Position? position = await _locationService.obterLocalizacaoAtual();
      
      if (position == null) {
        throw Exception('Não foi possível obter a localização.');
      }

      // 2. Capturar a foto
      final String? path = await _cameraService.tirarFoto();

      // 3. Tratar caso o usuário cancele a captura
      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Captura de foto cancelada.')),
          );
        }
        return;
      }

      // 4. Criar objeto Ponto
      final novoPonto = Ponto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dataHora: DateTime.now(),
        fotoPath: path,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 5. Salvar no Banco de Dados
      await _dbService.inserirPonto(novoPonto);

      // 6. Atualizar Lista
      await _carregarPontos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ponto registrado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Ponto'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _baterPonto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Bater Ponto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
          const Divider(height: 40),
          const Text(
            'Histórico de Pontos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pontos.isEmpty
                    ? const Center(child: Text('Nenhum ponto registrado.'))
                    : RefreshIndicator(
                        onRefresh: _carregarPontos,
                        child: ListView.builder(
                          itemCount: _pontos.length,
                          itemBuilder: (context, index) {
                            final ponto = _pontos[index];
                            return ListTile(
                              leading: ponto.fotoPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.file(
                                        File(ponto.fotoPath!),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : const Icon(Icons.access_time),
                              title: Text(DateFormat('dd/MM/yyyy - HH:mm:ss').format(ponto.dataHora)),
                              subtitle: Text('Lat: ${ponto.latitude?.toStringAsFixed(4)}, Long: ${ponto.longitude?.toStringAsFixed(4)}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
