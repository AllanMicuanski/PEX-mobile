import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';
import '../config/theme.dart';
import '../widgets/app_card.dart';
import '../widgets/status_chip.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final PontoService _pontoService = PontoService();
  List<Ponto> _pontos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _carregando = true);
    try {
      final pontos = await _pontoService.buscarHistoricoDePontos();
      // Ordenar por data descendente
      pontos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
      setState(() => _pontos = pontos);
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SizebayColors.offWhite,
      appBar: AppBar(
        title: const Text('Histórico'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: SizebayColors.coral),
            )
          : _pontos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: SizebayColors.cinzaMedio,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum registro encontrado',
                    style: TextStyle(
                      color: SizebayColors.cinzaMedio,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarHistorico,
              color: SizebayColors.coral,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _pontos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ponto = _pontos[index];
                  return _buildPontoTile(ponto);
                },
              ),
            ),
    );
  }

  Widget _buildPontoTile(Ponto ponto) {
    final data = DateFormat('dd/MM/yyyy').format(ponto.dataHora);
    final hora = DateFormat('HH:mm').format(ponto.dataHora);
    final tipo = ponto.tipo.toString().split('.').last;

    Color corTipo = SizebayColors.coral;
    IconData icone = Icons.login;
    if (tipo == 'almoco') {
      corTipo = SizebayColors.laranja;
      icone = Icons.restaurant;
    } else if (tipo == 'retorno') {
      corTipo = SizebayColors.azul;
      icone = Icons.logout;
    } else if (tipo == 'saida') {
      corTipo = SizebayColors.vermelho;
      icone = Icons.exit_to_app;
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: corTipo.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: corTipo, width: 2),
          ),
          child: Center(child: Icon(icone, color: corTipo, size: 24)),
        ),
        title: Text(
          '$data - $hora',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: SizebayColors.preto,
          ),
        ),
        subtitle: Row(
          children: [
            StatusChip(color: corTipo, label: tipo.toUpperCase()),
            const Spacer(),
            const StatusChip(
              color: SizebayColors.verde,
              label: 'Registrado',
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }
}
