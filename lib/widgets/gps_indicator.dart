import 'package:flutter/material.dart';
import '../config/theme.dart';

class GPSIndicator extends StatelessWidget {
  final bool isValid;

  const GPSIndicator({super.key, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final cor = isValid ? SizebayColors.verde : SizebayColors.vermelho;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isValid ? Icons.location_on : Icons.location_off,
          color: cor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          isValid ? 'GPS validado' : 'Fora do raio permitido',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cor,
          ),
        ),
      ],
    );
  }
}
