import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/continuous_monitoring_bloc/bloc/continuous_monitoring_bloc.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/connect_ring_page.dart';
import 'package:intl/intl.dart';

class BodyMetricsScreen extends StatefulWidget {
  final int dayIndex;
  const BodyMetricsScreen({super.key, required this.dayIndex});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen>
    with TickerProviderStateMixin {
  int selectedDateRange = 0;
  DateTime selectedDate = DateTime.now();
  late AnimationController _dotAnimationController;
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().subtract(Duration(days: widget.dayIndex));
    _dotAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _borderAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _borderAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ContinuousMonitoringBloc>()
          .add(GetHeartRateData(dayIndices: [widget.dayIndex]));
    });
  }

  @override
  void dispose() {
    _dotAnimationController.dispose();
    _borderAnimationController.dispose();
    super.dispose();
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

      final now = DateTime.now();
      final difference = now.difference(picked).inDays;

      context
          .read<ContinuousMonitoringBloc>()
          .add(GetHeartRateData(dayIndices: [difference]));
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
          'Body Metrics Trends',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          BlocBuilder<ContinuousMonitoringBloc, BluethoothInteractionsState>(
            buildWhen: (previous, current) => current is HeartRateDataReceived,
            builder: (context, state) {
              if (state is HeartRateDataReceived) {
                // Debug prints for blood oxygen data
                print(
                    'Raw blood oxygen data: ${state.combinedHealthData.bloodOxygenData}');

                // Process heart rate data
                final nonZeroHeartRates = state
                    .combinedHealthData.heartRateData.first.heartRates
                    .where((rate) => rate > 0)
                    .toList();

                // Create heart rate spots
                final heartRateSpots = nonZeroHeartRates
                    .asMap()
                    .entries
                    .map((entry) =>
                        FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                    .toList();

                // Process blood oxygen data
                final validSpO2Readings = state
                    .combinedHealthData.bloodOxygenData
                    .where((data) => data.bloodOxygenLevels.first > 0)
                    .toList();

                print('Valid SpO2 readings: $validSpO2Readings');
                print('Number of valid readings: ${validSpO2Readings.length}');

                // Create SpO2 spots based on timestamp and ensure valid values
                final spO2Spots = validSpO2Readings.map((data) {
                  final hour = DateTime.fromMillisecondsSinceEpoch(
                    (data.date * 1000).round(),
                  ).hour.toDouble();
                  final value = data.bloodOxygenLevels.first;
                  // Ensure value is between 95 and 100
                  final clampedValue = value.clamp(95.0, 100.0);
                  return FlSpot(hour, clampedValue);
                }).toList();

                // Sort spots by hour to prevent line connection issues
                spO2Spots.sort((a, b) => a.x.compareTo(b.x));

                // Calculate averages for display
                final avgHeartRate = nonZeroHeartRates.isEmpty
                    ? 0
                    : nonZeroHeartRates.reduce((a, b) => a + b) /
                        nonZeroHeartRates.length;

                final avgSpO2 = validSpO2Readings.isEmpty
                    ? 0.0
                    : validSpO2Readings
                            .map((data) => data.bloodOxygenLevels.first)
                            .reduce((a, b) => a + b) /
                        validSpO2Readings.length;

                print('Calculated average SpO2: $avgSpO2');

                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 120),
                        // Date range selector row
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
                            const SizedBox(width: 15),
                            DateRange(
                              text: '7-day',
                              isSelected: selectedDateRange == 1,
                              onTap: () {
                                setState(() {
                                  selectedDateRange = 1;
                                });
                              },
                            ),
                            const SizedBox(width: 15),
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
                        // Update the date container to be interactive
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
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: CustomTheme.surfacePrimary,
                        ),
                        const SizedBox(height: 30),
                        // Heart Rate Chart
                        MetricChart(
                          title: 'Heart rate',
                          value: '${avgHeartRate.round()}',
                          unit: 'bpm',
                          spots: heartRateSpots,
                          legendLabel: 'BPM',
                          minY: 30,
                          maxY: 150,
                          interval: 20,
                        ),
                        const SizedBox(height: 30),
                        // Blood Oxygen Chart
                        MetricChart(
                          title: 'Blood Oxygen',
                          value: avgSpO2 == 0
                              ? 'No data'
                              : avgSpO2.toStringAsFixed(1),
                          unit: '%',
                          spots: spO2Spots,
                          legendLabel: '%',
                          minY: 95,
                          maxY: 100,
                          interval: 1,
                          minX: 0,
                          maxX: 24,
                          preventCurve: true,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: BlocBuilder<ContinuousMonitoringBloc,
                              BluethoothInteractionsState>(
                            builder: (context, state) {
                              return GestureDetector(
                                onTap: () {
                                  context.read<ContinuousMonitoringBloc>().add(
                                        const StartMeasurement(
                                            0), // 0 for heart rate type
                                      );
                                },
                                child: AnimatedBuilder(
                                  animation: _borderAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: state is MeasurementStarted
                                            ? SweepGradient(
                                                center: Alignment.center,
                                                startAngle: 0,
                                                endAngle: 2 * pi,
                                                transform: GradientRotation(
                                                    _borderAnimation.value),
                                                colors: const [
                                                  Color.fromARGB(
                                                      255, 198, 3, 252),
                                                  Colors.transparent,
                                                  Color.fromARGB(
                                                      255, 3, 173, 252),
                                                  Colors.transparent,
                                                ],
                                              )
                                            : null,
                                      ),
                                      padding: const EdgeInsets.all(
                                          2), // Border width
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: state is MeasurementFinished
                                                ? Colors.red
                                                : Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (state is MeasurementStarted)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TweenAnimationBuilder(
                                                    tween: Tween(
                                                        begin: 1.0, end: 1.2),
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut,
                                                    builder: (context, value,
                                                        child) {
                                                      return Transform.scale(
                                                        scale: value,
                                                        child: const Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                          size: 24,
                                                        ),
                                                      );
                                                    },
                                                    onEnd: () {
                                                      setState(() {});
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  AnimatedBuilder(
                                                    animation:
                                                        _dotAnimationController,
                                                    builder: (context, child) {
                                                      final value =
                                                          (_dotAnimationController
                                                                      .value *
                                                                  3)
                                                              .floor();
                                                      return Text(
                                                        'Reading${'.' * value}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            if (state is MeasurementFinished)
                                              Text(
                                                '${state.heartBeat} BPM',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (state is! MeasurementFinished &&
                                                state is! MeasurementStarted)
                                              const Text(
                                                'Measure Heart Rate',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (state is MeasurementError)
                                              const Icon(
                                                Icons.error,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

class DateRange extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const DateRange({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: CustomTheme.surfacePrimary.withOpacity(0.35),
          border: Border.all(
            color: isSelected
                ? CustomTheme.primaryDefault
                : CustomTheme.surfacePrimary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? CustomTheme.primaryDefault : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class MetricChart extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final List<FlSpot> spots;
  final String legendLabel;
  final double minY;
  final double maxY;
  final double interval;
  final double minX;
  final double maxX;
  final bool preventCurve;

  const MetricChart({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.spots,
    required this.legendLabel,
    required this.minY,
    required this.maxY,
    required this.interval,
    this.minX = 0,
    this.maxX = 24,
    this.preventCurve = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: 1,
              color: CustomTheme.primaryDefault,
            ),
            const SizedBox(width: 5),
            Text(
              legendLabel,
              style: const TextStyle(
                color: CustomTheme.textColorSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.85),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: Colors.white.withOpacity(0.85),
                    width: 1,
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 3,
                    getTitlesWidget: (value, meta) {
                      if (value % 3 == 0) {
                        final hour = value.toInt();
                        return Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 1,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: !preventCurve,
                  color: CustomTheme.primaryDefault,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.black,
                        strokeWidth: 2,
                        strokeColor: CustomTheme.primaryDefault,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: CustomTheme.primaryDefault.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
