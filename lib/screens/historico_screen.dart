import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';

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
      appBar: AppBar(title: const Text('Histórico'), centerTitle: true),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _pontos.isEmpty
          ? const Center(child: Text('Nenhum registro encontrado'))
          : RefreshIndicator(
              onRefresh: _carregarHistorico,
              child: ListView.separated(
                itemCount: _pontos.length,
                separatorBuilder: (_, _) => const Divider(),
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(Icons.access_time, color: Colors.blue[600])),
      ),
      title: Text(
        '$data - $hora',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          Text(tipo, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
        ],
      ),
    );
  }
}
