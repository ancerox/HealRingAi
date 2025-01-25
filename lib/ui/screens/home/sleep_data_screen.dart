import 'package:flutter/material.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/ui/screens/home/body_metrics_screen.dart';

class SleepDataScreen extends StatefulWidget {
  const SleepDataScreen({super.key});

  @override
  State<SleepDataScreen> createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreen> {
  int selectedDateRange = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sleep',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // const GradientBackground(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DateRange(
                        text: '1-day',
                        isSelected: selectedDateRange == 0,
                        onTap: () {
                          setState(() {
                            selectedDateRange = 0;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      DateRange(
                        text: '7-day',
                        isSelected: selectedDateRange == 1,
                        onTap: () {
                          setState(() {
                            selectedDateRange = 1;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      DateRange(
                        text: '30-day',
                        isSelected: selectedDateRange == 2,
                        onTap: () {
                          setState(() {
                            selectedDateRange = 2;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)),
                            Text('Tuesday 17 January, 2023',
                                style: TextStyle(
                                    color: CustomTheme.textColorSecondary)),
                          ],
                        ),
                        Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: 0.88, // 88%
                            strokeWidth: 12,
                            backgroundColor: Colors.black.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CD6B4), // Teal color as shown in image
                            ),
                          ),
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '79',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Good',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Sleep cycle graph
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your sleep cycle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: CustomPaint(
                            painter: SleepCyclePainter(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('{H INI}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                            Text('03:00',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                            Text('06:00',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                            Text('09:00',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                            Text('12:00',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                            Text('15:00',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                            Text('{FINAL H}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Sleep stages list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your sleep cycle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sleep stages list
                        _buildSleepStage(
                          color: Colors.white,
                          title: 'Awake',
                          duration: '2h 30min',
                          percentage: '33% of sleep session',
                          status: 'Elevated',
                          statusColor: const Color(0xFFD4A373),
                        ),
                        _buildSleepStage(
                          color: const Color(0xFF4CD6B4),
                          title: 'R.E.M.',
                          duration: '22min',
                          percentage: '5% of sleep session',
                          status: 'Low',
                          statusColor: const Color(0xFFD4A373),
                        ),
                        _buildSleepStage(
                          color: const Color(0xFFB4E4D7),
                          title: 'Light sleep',
                          duration: '3h 15min',
                          percentage: '43% of sleep session',
                          status: 'Normal',
                          statusColor: const Color(0xFF4CD6B4),
                        ),
                        _buildSleepStage(
                          color: const Color(0xFF2A9D8F),
                          title: 'Deep sleep',
                          duration: '1h 30min',
                          percentage: '20% of sleep session',
                          status: 'Normal',
                          statusColor: const Color(0xFF4CD6B4),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 40),
                  // Add after the sleep cycle graph section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.6,
                      children: [
                        _buildMetricCard(
                          value: '8h 25min',
                          label: 'Sleep duration',
                        ),
                        _buildMetricCard(
                          value: '25 min',
                          label: 'Duration to fall sleep',
                        ),
                        _buildMetricCard(
                          value: 'Good',
                          label: 'Sleep quality',
                        ),
                        _buildMetricCard(
                          value: '92%',
                          label: 'Sleep efficiency',
                        ),
                        _buildMetricCard(
                          value: '42 ms',
                          label: 'Heart rate variability',
                        ),
                        _buildMetricCard(
                          value: '51 bpm',
                          label: 'Resting heart rate',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStage({
    required Color color,
    required String title,
    required String duration,
    required String percentage,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                Text(
                  percentage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                status == 'Normal'
                    ? Icons.check_circle
                    : Icons.arrow_circle_down,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfacePrimary,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class SleepCyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const awakeColor = Colors.white;
    const remColor = Color(0xFF4CD6B4);
    const lightSleepColor = Color(0xFFB4E4D7);
    const deepSleepColor = Color(0xFF2A9D8F);

    // Define your sleep stages data here
    // Each list entry is [startX, endX, startY, endY, color]
    final stages = [
      [0.0, 0.1, 0.2, 0.3, awakeColor],
      [0.1, 0.2, 0.6, 0.8, lightSleepColor],
      [0.2, 0.3, 0.4, 0.5, remColor],
      [0.3, 0.4, 0.7, 0.9, deepSleepColor],
      [0.4, 0.5, 0.3, 0.4, awakeColor],
      [0.5, 0.6, 0.5, 0.7, lightSleepColor],
      [0.6, 0.7, 0.8, 0.9, deepSleepColor],
      [0.7, 0.8, 0.4, 0.5, remColor],
      [0.8, 0.9, 0.6, 0.7, lightSleepColor],
      [0.9, 1.0, 0.3, 0.4, awakeColor],
    ];

    // Draw connecting lines first (behind the blocks)
    for (int i = 0; i < stages.length - 1; i++) {
      final currentStage = stages[i];
      final nextStage = stages[i + 1];

      final startX = size.width * (currentStage[1] as double);
      final startY = size.height *
          (((currentStage[2] as double) + (currentStage[3] as double)) / 2);
      final endX = size.width * (nextStage[0] as double);
      final endY = size.height *
          (((nextStage[2] as double) + (nextStage[3] as double)) / 2);

      linePaint.color = currentStage[4] as Color;

      final path = Path()
        ..moveTo(startX, startY)
        ..lineTo(endX, endY);

      canvas.drawPath(path, linePaint);
    }

    // Draw the blocks
    for (final stage in stages) {
      paint.color = stage[4] as Color;
      final rect = Rect.fromLTRB(
        size.width * (stage[0] as double),
        size.height * (stage[2] as double),
        size.width * (stage[1] as double),
        size.height * (stage[3] as double),
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
