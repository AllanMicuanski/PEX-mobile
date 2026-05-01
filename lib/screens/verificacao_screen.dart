import 'package:flutter/material.dart';

class VerificacaoScreen extends StatefulWidget {
  const VerificacaoScreen({super.key});

  @override
  State<VerificacaoScreen> createState() => _VerificacaoScreenState();
}

class _VerificacaoScreenState extends State<VerificacaoScreen> {
  bool _fotoTirada = false;
  bool _gpsValidado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Ponto'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checklist de Verificação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Foto
            _buildVerificationItem(
              icon: Icons.camera_alt,
              title: 'Foto Capturada',
              isChecked: _fotoTirada,
              onTap: () {
                setState(() => _fotoTirada = !_fotoTirada);
              },
            ),
            const SizedBox(height: 16),
            // GPS
            _buildVerificationItem(
              icon: Icons.location_on,
              title: 'GPS Validado',
              isChecked: _gpsValidado,
              onTap: () {
                setState(() => _gpsValidado = !_gpsValidado);
              },
            ),
            const Spacer(),
            // Botão confirmar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_fotoTirada && _gpsValidado) ? () {} : null,
                child: const Text('CONFIRMAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem({
    required IconData icon,
    required String title,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isChecked ? Colors.green : Colors.grey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isChecked ? Colors.green : Colors.grey,
                ),
              ),
            ),
            Icon(
              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isChecked ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
