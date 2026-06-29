import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';
import '../config/theme.dart';
import '../widgets/app_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/skeleton_box.dart';

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
      pontos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
      if (mounted) setState(() => _pontos = pontos);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: _carregando
          ? _buildSkeleton()
          : _pontos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _carregarHistorico,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: _pontos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildPontoTile(_pontos[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Nenhum registro encontrado',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: 7,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => AppCard(
        child: Row(
          children: [
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 150, height: 14),
                SizedBox(height: 10),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ],
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: corTipo.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icone, color: corTipo, size: 22)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$data · $hora',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusChip(color: corTipo, label: tipo.toUpperCase()),
                    const SizedBox(width: 8),
                    const StatusChip(
                      color: SizebayColors.verde,
                      label: 'Registrado',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
