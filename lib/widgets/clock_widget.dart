import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 500), _updateTime);
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() => _currentTime = DateTime.now());
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('HH:mm:ss').format(_currentTime);

    return Text(
      formattedTime,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue[600],
      ),
    );
  }
}
