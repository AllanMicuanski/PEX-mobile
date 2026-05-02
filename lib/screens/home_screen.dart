import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';
import '../services/location_service.dart';
import '../services/jornada_service.dart';
import '../widgets/clock_widget.dart';
import '../widgets/gps_indicator.dart';
import '../config/theme.dart';
import '../services/ponto_service.dart' show Empresa;
import 'confirmacao_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PontoService _pontoService = PontoService();

  List<Ponto> _today = [];
  bool _estaProcessando = false;
  bool _gpsValido = false;
  bool _homeOffice = false;
  String _horasTrabalhadas = '0h 00min';

  @override
  void initState() {
    super.initState();
    // Inicializa o serviço de localização
    LocationService.initialize();
    _carregarDados();
    _verificarGPS();
  }

  Future<void> _verificarGPS() async {
    if (_homeOffice) {
      setState(() => _gpsValido = true);
      return;
    }

    try {
      final valido = await _pontoService.validarGPS();
      if (mounted) {
        setState(() => _gpsValido = valido);
      }
    } catch (e) {
      print('GPS validation error: $e');
      if (mounted) {
        setState(() => _gpsValido = false);
      }
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
    if (!_gpsValido && !_homeOffice) {
      _mostrarMensagem(
        '📍 GPS não validado! Você precisa estar a 500m da empresa.',
        isError: true,
      );
      return;
    }

    setState(() => _estaProcessando = true);
    try {
      await _pontoService.registrarPontoCompleto(homeOffice: _homeOffice);
      await _carregarDados();
      
      // Mostra modal de confirmação
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ConfirmacaoScreen(),
      ).then((_) {
        // Refresh após fechar modal
        _verificarGPS();
      });
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
        backgroundColor: isError ? Colors.red : SizebayColors.coral,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SizebayColors.offWhite,
      appBar: AppBar(
        title: const Text('Controle de Ponto'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        color: SizebayColors.coral,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Header com relógio e GPS
            _buildHeader(),
            const SizedBox(height: 24),

            // Flag Home Office
            _buildHomeOfficeToggle(),
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
        if (!_homeOffice) GPSIndicator(isValid: _gpsValido),
        if (_homeOffice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SizebayColors.azulClaro.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SizebayColors.azulClaro, width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: SizebayColors.azulClaro, size: 20),
                SizedBox(width: 8),
                Text(
                  'Modo Home Office Ativado',
                  style: TextStyle(
                    color: SizebayColors.azulClaro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHomeOfficeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _homeOffice ? SizebayColors.coral : SizebayColors.bege,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: SizebayColors.coral.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home Office',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SizebayColors.preto,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Desativar validação GPS',
                  style: TextStyle(
                    fontSize: 12,
                    color: SizebayColors.cinzaMedio,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: _homeOffice,
              onChanged: (value) {
                setState(() => _homeOffice = value);
                _verificarGPS();
              },
              activeColor: SizebayColors.coral,
              activeTrackColor: SizebayColors.coral.withOpacity(0.3),
              inactiveThumbColor: SizebayColors.cinzaMedio,
              inactiveTrackColor: SizebayColors.cinzaMedio.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    final tempoSaida = JornadaService.isHorarioDeSaida(DateTime.now());

    return Center(
      child: GestureDetector(
        onTap: _estaProcessando || (!_gpsValido && !_homeOffice)
            ? null
            : _handleRegistrarPonto,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: tempoSaida
                  ? [Colors.red[600]!, Colors.red[400]!]
                  : [SizebayColors.coral, const Color(0xFFF7663D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (tempoSaida ? Colors.red : SizebayColors.coral)
                    .withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _estaProcessando
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
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
                          letterSpacing: 1.2,
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SizebayColors.preto,
          ),
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

    Color corBorda = SizebayColors.bege;
    Color corTexto = SizebayColors.cinzaMedio;
    IconData icone = Icons.schedule;

    if (temRegistro) {
      if (status == 'no_horario') {
        corBorda = SizebayColors.verde;
        corTexto = SizebayColors.verde;
        icone = Icons.check_circle;
      } else if (status == 'atrasado') {
        corBorda = SizebayColors.laranja;
        corTexto = SizebayColors.laranja;
        icone = Icons.schedule;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBorda, width: 2),
        boxShadow: [
          BoxShadow(
            color: corBorda.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
        gradient: LinearGradient(
          colors: [
            SizebayColors.azulClaro.withOpacity(0.2),
            SizebayColors.bege.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SizebayColors.azulClaro, width: 2),
        boxShadow: [
          BoxShadow(
            color: SizebayColors.azulClaro.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horas Trabalhadas',
                style: TextStyle(
                  fontSize: 14,
                  color: SizebayColors.cinzaMedio,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _horasTrabalhadas,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: SizebayColors.coral,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SizebayColors.coral.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer,
              size: 48,
              color: SizebayColors.coral,
            ),
          ),
        ],
      ),
    );
  }
}
