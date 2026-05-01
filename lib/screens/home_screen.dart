import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';
import '../services/location_service.dart';
import '../services/jornada_service.dart';
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
  bool _gpsValido = false;
  String _horasTrabalhadas = '0h 00min';

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
    try {
      final pontos = await _pontoService.buscarHistoricoDePontos();
      final hoje = DateTime.now();
      final registrosHoje = pontos.where((p) {
        return p.dataHora.year == hoje.year &&
            p.dataHora.month == hoje.month &&
            p.dataHora.day == hoje.day;
      }).toList();
      setState(() {
        _today = registrosHoje;
        _horasTrabalhadas = JornadaService.calcularHorasDia(_today);
      });
    } finally {
      // reload completed
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
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Header com relógio e GPS
            _buildHeader(),
            const SizedBox(height: 32),

            // Botão grande circular
            _buildMainButton(),
            const SizedBox(height: 40),

            // 4 slots do dia
            _buildSlotsDia(),
            const SizedBox(height: 32),

            // Horas trabalhadas
            _buildHorasTrabalhadas(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const ClockWidget(),
        const SizedBox(height: 24),
        GPSIndicator(isValid: _gpsValido),
      ],
    );
  }

  Widget _buildMainButton() {
    final tempoSaida = JornadaService.isHorarioDeSaida(DateTime.now());
    final corBotao = tempoSaida ? Colors.red : Colors.blue;

    return Center(
      child: GestureDetector(
        onTap: _estaProcessando ? null : _handleRegistrarPonto,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: corBotao[600],
            boxShadow: [
              BoxShadow(
                color: corBotao.withValues(alpha: 0.3),
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
                        tempoSaida ? Icons.logout : Icons.check_circle_outline,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tempoSaida ? 'SAÍDA' : 'ENTRADA',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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

  Widget _buildSlotsDia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jornada do Dia',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: JornadaService.horariosFixos
              .map((horario) => _buildSlotCard(horario))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSlotCard(HorarioJornada horario) {
    Ponto? pontoRegistrado;
    try {
      pontoRegistrado = _today.firstWhere((p) => p.tipo == horario.tipo);
    } catch (_) {
      pontoRegistrado = null;
    }

    final temRegistro = pontoRegistrado != null;
    final status = temRegistro
        ? JornadaService.statusPonto(pontoRegistrado)
        : 'pendente';

    Color corFundo = Colors.grey[100]!;
    Color corTexto = Colors.grey[600]!;
    IconData icone = Icons.schedule;

    if (temRegistro) {
      if (status == 'no_horario') {
        corFundo = Colors.green[50]!;
        corTexto = Colors.green[700]!;
        icone = Icons.check_circle;
      } else if (status == 'atrasado') {
        corFundo = Colors.orange[50]!;
        corTexto = Colors.orange[700]!;
        icone = Icons.schedule;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corTexto, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: corTexto, size: 32),
          const SizedBox(height: 8),
          Text(
            horario.label,
            style: TextStyle(
              fontSize: 12,
              color: corTexto,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            horario.toString(),
            style: TextStyle(
              fontSize: 14,
              color: corTexto,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (temRegistro)
            Text(
              DateFormat('HH:mm').format(pontoRegistrado.dataHora),
              style: TextStyle(fontSize: 11, color: corTexto),
            ),
        ],
      ),
    );
  }

  Widget _buildHorasTrabalhadas() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horas Trabalhadas',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _horasTrabalhadas,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          Icon(Icons.timer, size: 48, color: Colors.blue[300]),
        ],
      ),
    );
  }
}
