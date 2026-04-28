import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PontoService _pontoService = PontoService();
  
  List<Ponto> _historico = [];
  bool _estaProcessando = false;
  bool _carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregandoHistorico = true);
    try {
      final pontos = await _pontoService.buscarHistoricoDePontos();
      setState(() => _historico = pontos);
    } finally {
      setState(() => _carregandoHistorico = false);
    }
  }

  Future<void> _handleRegistrarPonto() async {
    setState(() => _estaProcessando = true);
    
    try {
      await _pontoService.registrarPontoCompleto();
      await _carregarDados();
      _mostrarMensagem('Ponto registrado com sucesso!');
    } catch (e) {
      _mostrarMensagem(e.toString().replaceAll('Exception: ', ''), isError: true);
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
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildHeader(),
          const Divider(),
          _buildListTitle(),
          _buildHistoricoList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: _estaProcessando
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _handleRegistrarPonto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('BATER PONTO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
      ),
    );
  }

  Widget _buildListTitle() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Histórico de Registros',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHistoricoList() {
    if (_carregandoHistorico) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (_historico.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Nenhum registro encontrado.')),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _carregarDados,
        child: ListView.separated(
          itemCount: _historico.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) => _PontoTile(ponto: _historico[index]),
        ),
      ),
    );
  }
}

class _PontoTile extends StatelessWidget {
  final Ponto ponto;

  const _PontoTile({required this.ponto});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildThumbnail(),
      title: Text(
        DateFormat('dd/MM/yyyy - HH:mm:ss').format(ponto.dataHora),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Lat: ${ponto.latitude?.toStringAsFixed(4)}, Long: ${ponto.longitude?.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (ponto.fotoPath == null) return const Icon(Icons.history);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(ponto.fotoPath!),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 60,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }
}
