import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/continuous_monitoring_bloc/bloc/continuous_monitoring_bloc.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/widgets/factor_card_widget.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/widgets/life_graph_widget.dart';

class LifeSpanScreen extends StatelessWidget {
  const LifeSpanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ContinuousMonitoringBloc, BluethoothInteractionsState>(
        builder: (context, state) {
          if (state is HomeDataRecevied) {
            // final lifeExpectancy = _calculateLifeExpectancy(state);
            // final progress = (lifeExpectancy / 100.0).clamp(0.0, 1.0);

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 35),
                    SizedBox(
                      width: 350,
                      height: 350,
                      child: CustomPaint(
                        painter: RadialProgressPainter(
                          progress: 2,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          progressColor:
                              CustomTheme.primaryDefault.withOpacity(0.8),
                          strokeWidth: 45,
                        ),
                        child: Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF24DBC9),
                                  Color(0xFFBEEEE8),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    2.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'years',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '0 years',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '100 years',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'What shapes your lifespan?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'These are the key factors we analyze to estimate your life expectancy. Improve them to live longer and healthier!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 400,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 6,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                              ),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FactorCard(
                                  percentage: '20%',
                                  label: 'Heart Rate',
                                  value: state.avgHeartRate != null
                                      ? '${state.avgHeartRate!.toStringAsFixed(0)} bpm'
                                      : 'No data',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Disclaimer: HealthAI Ring provides educational health information based on your input, not medical advice or personalized counseling. Always consult a healthcare professional before making significant health decisions.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
