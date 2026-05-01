import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmacaoScreen extends StatelessWidget {
  const ConfirmacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final horaFormatada = DateFormat('HH:mm:ss').format(agora);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmação'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            // Ícone de sucesso
            Icon(Icons.check_circle, size: 80, color: Colors.green[600]),
            const SizedBox(height: 24),
            // Título
            Text(
              'PONTO\nREGISTRADO',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            // Detalhes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Horário', horaFormatada),
                  const Divider(),
                  _buildDetailRow('Foto', '✓', color: Colors.green),
                  const Divider(),
                  _buildDetailRow('Localização', '✓', color: Colors.green),
                ],
              ),
            ),
            const Spacer(),
            // Botão voltar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('VOLTAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
