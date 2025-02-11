import 'package:flutter/material.dart';
import 'package:health_ring_ai/core/app.dart';

class TimeToLifeScreen extends StatelessWidget {
  const TimeToLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainAppScaffold(
      child: Center(child: Text('Time to life')),
    );
  }
}
