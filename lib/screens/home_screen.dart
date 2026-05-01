import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';
import '../services/location_service.dart';
import '../widgets/clock_widget.dart';
import '../widgets/gps_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PontoService _pontoService = PontoService();
  final LocationService _locationService = LocationService();

  List<Ponto> _today = [];
  bool _estaProcessando = false;
  bool _carregandoHistorico = true;
  bool _gpsValido = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _verificarGPS();
  }

  Future<void> _verificarGPS() async {
    try {
      await _locationService.obterLocalizacaoAtual();
      setState(() => _gpsValido = true);
    } catch (_) {
      setState(() => _gpsValido = false);
    }
  }

  Future<void> _carregarDados() async {
    setState(() => _carregandoHistorico = true);
    try {
      final pontos = await _pontoService.buscarHistoricoDePontos();
      final hoje = DateTime.now();
      final registrosHoje = pontos.where((p) {
        return p.dataHora.year == hoje.year &&
            p.dataHora.month == hoje.month &&
            p.dataHora.day == hoje.day;
      }).toList();
      setState(() => _today = registrosHoje);
    } finally {
      setState(() => _carregandoHistorico = false);
    }
  }

  Future<void> _handleRegistrarPonto() async {
    if (!_gpsValido) {
      _mostrarMensagem('GPS não validado!', isError: true);
      return;
    }

    setState(() => _estaProcessando = true);
    try {
      await _pontoService.registrarPontoCompleto();
      await _carregarDados();
      _mostrarMensagem('Ponto registrado com sucesso!');
    } catch (e) {
      _mostrarMensagem(
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      setState(() => _estaProcessando = false);
    }
  }

  void _mostrarMensagem(String mensagem, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Ponto'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          // Header com relógio e GPS
          _buildHeader(),
          const SizedBox(height: 48),

          // Botão grande circular de bater ponto
          _buildMainButton(),
          const SizedBox(height: 48),

          // Registros do dia
          _buildTodayRecords(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Relógio
        const ClockWidget(),
        const SizedBox(height: 24),

        // GPS Indicator
        GPSIndicator(isValid: _gpsValido),
      ],
    );
  }

  Widget _buildMainButton() {
    return Center(
      child: GestureDetector(
        onTap: _estaProcessando ? null : _handleRegistrarPonto,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[600],
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: _estaProcessando
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'BATER\nPONTO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayRecords() {
    if (_carregandoHistorico) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registros de Hoje',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_today.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhum registro ainda',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._today.map((ponto) => _buildTodayTile(ponto)),
      ],
    );
  }

  Widget _buildTodayTile(Ponto ponto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: Colors.blue[600]!, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(ponto.dataHora),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    if (ponto.fotoPath != null)
                      const Text(
                        'Foto ✓',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'GPS ✓',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
