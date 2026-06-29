import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';
import '../services/location_service.dart';
import '../services/jornada_service.dart';
import '../widgets/clock_widget.dart';
import '../widgets/app_card.dart';
import '../widgets/status_chip.dart';
import '../config/theme.dart';
import 'confirmacao_screen.dart';

const List<String> _mesesAbrev = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

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
  bool _pressed = false;
  String _horasTrabalhadas = '0h 00min';

  @override
  void initState() {
    super.initState();
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
    } catch (_) {
      if (mounted) {
        setState(() => _gpsValido = false);
      }
    }
  }

  Future<void> _carregarDados() async {
    final pontos = await _pontoService.buscarHistoricoDePontos();
    final hoje = DateTime.now();
    final registrosHoje = pontos.where((p) {
      return p.dataHora.year == hoje.year &&
          p.dataHora.month == hoje.month &&
          p.dataHora.day == hoje.day;
    }).toList();
    if (!mounted) return;
    setState(() {
      _today = registrosHoje;
      _horasTrabalhadas = JornadaService.calcularHorasDia(_today);
    });
  }

  Future<void> _handleRegistrarPonto() async {
    if (!_gpsValido && !_homeOffice) {
      _mostrarMensagem(
        'GPS não validado. Você precisa estar a 500m da empresa.',
        isError: true,
      );
      return;
    }

    setState(() => _estaProcessando = true);
    try {
      await _pontoService.registrarPontoCompleto(homeOffice: _homeOffice);
      await _carregarDados();

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ConfirmacaoScreen(),
      ).then((_) => _verificarGPS());
    } catch (e) {
      _mostrarMensagem(
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _estaProcessando = false);
    }
  }

  void _mostrarMensagem(String mensagem, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? SizebayColors.vermelho : SizebayColors.coral,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Ponto? _pontoDoHorario(HorarioJornada horario) {
    final registros = _today.where((p) => p.tipo == horario.tipo);
    return registros.isEmpty ? null : registros.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Ponto')),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 28),
            _buildMainButton(),
            const SizedBox(height: 24),
            _buildHomeOfficeToggle(),
            const SizedBox(height: 28),
            _buildJornadaCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsChip() {
    if (_homeOffice) {
      return const StatusChip(
        color: SizebayColors.azul,
        label: 'Home office',
        icon: Icons.home_rounded,
      );
    }
    return _gpsValido
        ? const StatusChip(
            color: SizebayColors.verde,
            label: 'No raio',
            icon: Icons.location_on,
          )
        : const StatusChip(
            color: SizebayColors.vermelho,
            label: 'Fora do raio',
            icon: Icons.location_off,
          );
  }

  Widget _buildHeroCard() {
    final scheme = Theme.of(context).colorScheme;
    final agora = DateTime.now();
    final dataLabel = '${agora.day} de ${_mesesAbrev[agora.month - 1]}';
    final proximo = JornadaService.proximoHorario(_today);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dataLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              _buildGpsChip(),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: ClockWidget()),
          const SizedBox(height: 20),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                proximo != null
                    ? Icons.schedule
                    : Icons.check_circle_outline_rounded,
                size: 20,
                color: proximo != null ? scheme.primary : SizebayColors.verde,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  proximo != null
                      ? 'Próximo ponto: ${proximo.label} às $proximo'
                      : 'Todos os pontos de hoje registrados',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    final tempoSaida = JornadaService.isHorarioDeSaida(DateTime.now());
    final desabilitado = !_gpsValido && !_homeOffice;
    final habilitado = !_estaProcessando && !desabilitado;

    final corBase = desabilitado
        ? SizebayColors.cinzaMedio
        : tempoSaida
        ? SizebayColors.vermelho
        : SizebayColors.coral;
    final gradiente = desabilitado
        ? [SizebayColors.cinzaMedio, SizebayColors.cinzaMedio]
        : tempoSaida
        ? [SizebayColors.vermelho, const Color(0xFFFF8A85)]
        : [SizebayColors.coral, SizebayColors.coralClaro];

    return Center(
      child: Semantics(
        button: true,
        enabled: habilitado,
        label: tempoSaida ? 'Registrar saída' : 'Registrar entrada',
        child: GestureDetector(
          onTapDown: habilitado ? (_) => setState(() => _pressed = true) : null,
          onTapUp: habilitado ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: habilitado
              ? () => setState(() => _pressed = false)
              : null,
          onTap: habilitado ? _handleRegistrarPonto : null,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradiente,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: corBase.withValues(alpha: desabilitado ? 0.2 : 0.4),
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
                            desabilitado
                                ? Icons.lock_outline
                                : tempoSaida
                                ? Icons.logout
                                : Icons.check_circle_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            desabilitado
                                ? 'INDISPONÍVEL'
                                : tempoSaida
                                ? 'SAÍDA'
                                : 'ENTRADA',
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
        ),
      ),
    );
  }

  Widget _buildHomeOfficeToggle() {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home office',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Registrar sem validar o GPS',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _homeOffice,
            onChanged: (value) {
              setState(() => _homeOffice = value);
              _verificarGPS();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJornadaCard() {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Jornada de hoje',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                _horasTrabalhadas,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SizebayColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: JornadaService.horariosFixos
                .map((horario) => _buildTimelineNode(horario))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(HorarioJornada horario) {
    final scheme = Theme.of(context).colorScheme;
    final ponto = _pontoDoHorario(horario);
    final temRegistro = ponto != null;

    Color cor = scheme.onSurfaceVariant;
    IconData icone = Icons.circle_outlined;

    if (temRegistro) {
      final status = JornadaService.statusPonto(ponto);
      if (status == 'atrasado') {
        cor = SizebayColors.laranja;
        icone = Icons.schedule;
      } else {
        cor = SizebayColors.verde;
        icone = Icons.check_circle;
      }
    }

    return Expanded(
      child: Column(
        children: [
          Icon(icone, color: cor, size: 26),
          const SizedBox(height: 8),
          Text(
            horario.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            horario.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (temRegistro)
            Text(
              DateFormat('HH:mm').format(ponto.dataHora),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 11, color: cor),
            ),
        ],
      ),
    );
  }
}
