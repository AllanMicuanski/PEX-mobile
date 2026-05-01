import 'package:flutter/material.dart';

class GPSIndicator extends StatelessWidget {
  final bool isValid;

  const GPSIndicator({super.key, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on,
          color: isValid ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          isValid ? 'GPS OK' : 'GPS ERRO',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
