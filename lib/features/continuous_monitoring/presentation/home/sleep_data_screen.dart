import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/sleep_data.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/continuous_monitoring_bloc/bloc/continuous_monitoring_bloc.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/body_metrics_screen.dart';
import 'package:intl/intl.dart';

class SleepDataScreen extends StatefulWidget {
  final int dayDiff;
  const SleepDataScreen({super.key, required this.dayDiff});

  @override
  State<SleepDataScreen> createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreen> {
  int selectedDateRange = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Request sleep data when screen loads
    context.read<ContinuousMonitoringBloc>().add(GetSleepData(widget.dayDiff));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CD6B4),
              onPrimary: Colors.white,
              surface: CustomTheme.surfacePrimary,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: CustomTheme.surfacePrimary,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      // Calculate days difference from today
      final now = DateTime.now();
      final difference = now.difference(picked).inDays;

      // Request sleep data for selected date
      context.read<ContinuousMonitoringBloc>().add(GetSleepData(difference));
    }
  }

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
          BlocBuilder<ContinuousMonitoringBloc, BluethoothInteractionsState>(
            builder: (context, state) {
              if (state is SleepDataLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SleepDataError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is SleepDataReceived) {
                final sleepData = state.sleepData;
                final totalDuration = _calculateTotalDuration(sleepData);

                // Update the existing UI with real data
                return Center(
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
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedDate.day == DateTime.now().day
                                          ? 'Today'
                                          : selectedDate.day ==
                                                  DateTime.now()
                                                      .subtract(const Duration(
                                                          days: 1))
                                                      .day
                                              ? 'Yesterday'
                                              : DateFormat('EEEE')
                                                  .format(selectedDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEEE d MMMM, y')
                                          .format(selectedDate),
                                      style: const TextStyle(
                                        color: CustomTheme.textColorSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ],
                            ),
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
                                  backgroundColor:
                                      Colors.black.withOpacity(0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(
                                        0xFF4CD6B4), // Teal color as shown in image
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _calculateSleepScore(sleepData).toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _calculateSleepStatus(sleepData),
                                    style: const TextStyle(
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
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter:
                                      SleepCyclePainter(sleepStages: sleepData),
                                ),
                              ),
                              const SizedBox(height: 8),
                              sleepData.isNotEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            DateFormat('h:mm a').format(
                                                DateTime.parse(
                                                    sleepData.first.startTime)),
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6))),
                                        Text(
                                            DateFormat('h:mm a').format(
                                                DateTime.parse(
                                                    sleepData.last.startTime)),
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6))),
                                      ],
                                    )
                                  : Container()
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
                                duration:
                                    _calculateStageDuration(sleepData, 'awake'),
                                percentage: _calculateStagePercentage(
                                    sleepData, 'awake'),
                                status: 'Normal',
                                statusColor: const Color(0xFF4CD6B4),
                              ),

                              _buildSleepStage(
                                color: const Color(0xFFB4E4D7),
                                title: 'Light sleep',
                                duration:
                                    _calculateStageDuration(sleepData, 'light'),
                                percentage: _calculateStagePercentage(
                                    sleepData, 'light'),
                                status: 'Normal',
                                statusColor: const Color(0xFF4CD6B4),
                              ),
                              _buildSleepStage(
                                color: const Color(0xFF2A9D8F),
                                title: 'Deep sleep',
                                duration:
                                    _calculateStageDuration(sleepData, 'deep'),
                                percentage: _calculateStagePercentage(
                                    sleepData, 'deep'),
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
                                value: totalDuration,
                                label: 'Sleep duration',
                              ),
                              _buildMetricCard(
                                value:
                                    _calculateStageDuration(sleepData, 'awake'),
                                label: 'Duration to fall sleep',
                              ),
                              _buildMetricCard(
                                value: _calculateSleepStatus(sleepData),
                                label: 'Sleep quality',
                              ),
                              _buildMetricCard(
                                value:
                                    '${_calculateSleepEfficiency(sleepData)}%',
                                label: 'Sleep efficiency',
                              ),
                              _buildMetricCard(
                                value: '${_calculateAverageHRV(sleepData)} ms',
                                label: 'Heart rate variability',
                              ),
                              _buildMetricCard(
                                value:
                                    '${_calculateRestingHeartRate(sleepData)} bpm',
                                label: 'Resting heart rate',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('No sleep data available'));
            },
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

  // Add this method to calculate total sleep duration
  String _calculateTotalDuration(List<SleepData> sleepData) {
    int totalMinutes = sleepData
        .where((data) =>
            data.typeString != 'no_data' && data.typeString != 'not_worn')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  // Add this method to calculate sleep stage percentage
  String _calculateStagePercentage(
      List<SleepData> sleepData, String stageType) {
    int totalMinutes = sleepData
        .where((data) =>
            data.typeString != 'no_data' && data.typeString != 'not_worn')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    int stageMinutes = sleepData
        .where((data) => data.typeString == stageType)
        .fold(0, (sum, data) => sum + data.durationMinutes);

    if (totalMinutes == 0) return '0%';
    return '${((stageMinutes / totalMinutes) * 100).round()}%';
  }

  // Add this method to calculate sleep stage duration
  String _calculateStageDuration(List<SleepData> sleepData, String stageType) {
    int minutes = sleepData
        .where((data) => data.typeString == stageType)
        .fold(0, (sum, data) => sum + data.durationMinutes);

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}min';
    }
    return '${remainingMinutes}min';
  }

  String _calculateSleepStatus(List<SleepData> sleepData) {
    // Calculate total sleep duration in minutes
    final totalMinutes = sleepData
        .where((data) =>
            data.typeString != 'no_data' && data.typeString != 'not_worn')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    // Calculate percentages of each sleep stage
    final deepSleepMinutes = sleepData
        .where((data) => data.typeString == 'deep')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    final lightSleepMinutes = sleepData
        .where((data) => data.typeString == 'light')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    final awakeMinutes = sleepData
        .where((data) => data.typeString == 'awake')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    // Calculate percentages
    final deepSleepPercentage = (deepSleepMinutes / totalMinutes) * 100;
    final lightSleepPercentage = (lightSleepMinutes / totalMinutes) * 100;
    final awakePercentage = (awakeMinutes / totalMinutes) * 100;

    // Evaluate sleep quality based on duration and stages
    if (totalMinutes >= 480 &&
        deepSleepPercentage >= 20 &&
        awakePercentage <= 10) {
      return 'Perfect';
    } else if (totalMinutes >= 420 &&
        deepSleepPercentage >= 15 &&
        awakePercentage <= 15) {
      return 'Good';
    } else if (totalMinutes >= 360 &&
        deepSleepPercentage >= 10 &&
        awakePercentage <= 20) {
      return 'Normal';
    } else {
      return 'Bad';
    }
  }

  int _calculateSleepScore(List<SleepData> sleepData) {
    // Calculate total sleep duration in minutes
    final totalMinutes = sleepData
        .where((data) =>
            data.typeString != 'no_data' && data.typeString != 'not_worn')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    // Calculate percentages of each sleep stage
    final deepSleepMinutes = sleepData
        .where((data) => data.typeString == 'deep')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    final lightSleepMinutes = sleepData
        .where((data) => data.typeString == 'light')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    final awakeMinutes = sleepData
        .where((data) => data.typeString == 'awake')
        .fold(0, (sum, data) => sum + data.durationMinutes);

    // Calculate percentages
    final deepSleepPercentage = (deepSleepMinutes / totalMinutes) * 100;
    final lightSleepPercentage = (lightSleepMinutes / totalMinutes) * 100;
    final awakePercentage = (awakeMinutes / totalMinutes) * 100;

    // Base score (0-100) based on total sleep duration
    double score =
        (totalMinutes / 600) * 100; // 600 minutes (10 hours) is perfect
    score = score.clamp(0, 100);

    // Adjust score based on sleep stages
    score += (deepSleepPercentage - 20); // Ideal deep sleep is 20-25%
    score -= (awakePercentage - 10); // Ideal awake time is <10%
    score += (lightSleepPercentage - 55) * 0.5; // Ideal light sleep is 55-60%

    // Ensure score stays within 0-100 range
    score = score.clamp(0, 100);

    return score.round();
  }

  double _calculateSleepEfficiency(List<SleepData> sleepData) {
    // Implementation of calculateSleepEfficiency method
    // This is a placeholder and should be implemented based on your actual requirements
    return 0.0; // Placeholder return, actual implementation needed
  }

  double _calculateAverageHRV(List<SleepData> sleepData) {
    // Implementation of calculateAverageHRV method
    // This is a placeholder and should be implemented based on your actual requirements
    return 0.0; // Placeholder return, actual implementation needed
  }

  double _calculateRestingHeartRate(List<SleepData> sleepData) {
    // Implementation of calculateRestingHeartRate method
    // This is a placeholder and should be implemented based on your actual requirements
    return 0.0; // Placeholder return, actual implementation needed
  }
}

class SleepCyclePainter extends CustomPainter {
  final List<SleepData> sleepStages;

  SleepCyclePainter({required this.sleepStages});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const awakeColor = Colors.white;
    const lightSleepColor = Color(0xFFB4E4D7);
    const deepSleepColor = Color(0xFF2A9D8F);

    // Sort sleep stages by start time to ensure chronological order
    final sortedStages = List<SleepData>.from(sleepStages)
      ..sort((a, b) =>
          DateTime.parse(a.startTime).compareTo(DateTime.parse(b.startTime)));

    // Calculate total sleep duration in minutes
    final totalMinutes = sortedStages.fold(0.0, (sum, stage) {
      final start = DateTime.parse(stage.startTime);
      final end = DateTime.parse(stage.endTime);
      return sum + end.difference(start).inMinutes;
    });

    // Get the start time of the first stage
    final firstStartTime = DateTime.parse(sortedStages.first.startTime);

    // Convert sleep stages to coordinates
    final stages = sortedStages.map((stage) {
      final startTime = DateTime.parse(stage.startTime);
      final endTime = DateTime.parse(stage.endTime);

      // Get color based on sleep stage
      final color = stage.typeString == 'awake'
          ? awakeColor
          : stage.typeString == 'light'
              ? lightSleepColor
              : deepSleepColor;

      // Convert times to fractions of total sleep duration using minutes since first start
      final startFraction =
          startTime.difference(firstStartTime).inMinutes / totalMinutes;
      final endFraction =
          endTime.difference(firstStartTime).inMinutes / totalMinutes;

      // Determine Y positions based on stage type
      final startY = stage.typeString == 'awake'
          ? 0.05
          : stage.typeString == 'light'
              ? 0.5
              : 0.7;
      final endY = stage.typeString == 'awake'
          ? 0.25
          : stage.typeString == 'light'
              ? 0.7
              : 0.9;

      return [startFraction, endFraction, startY, endY, color];
    }).toList();

    // Draw connections between stages
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
        ..moveTo(startX, startY - 15)
        ..lineTo(endX, endY - 15);

      canvas.drawPath(path, linePaint);
    }

    // Draw the stage blocks
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
