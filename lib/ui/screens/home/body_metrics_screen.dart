import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooh_interaction_bloc/bloc/bluethooth_interactions_bloc.dart';
import 'package:health_ring_ai/ui/screens/onboarding/connect_ring_page.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
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
          'Body Metrics Trends',
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
          const GradientBackground(),
          BlocBuilder<BluethoothInteractionsBloc, BluethoothInteractionsState>(
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

                // Create SpO2 spots based on timestamp
                final spO2Spots = validSpO2Readings.map((data) {
                  final hour = DateTime.fromMillisecondsSinceEpoch(
                    (data.date * 1000).round(),
                  ).hour.toDouble();
                  final value = data.bloodOxygenLevels.first;
                  print('Creating SpO2 spot - Hour: $hour, Value: $value');
                  return FlSpot(hour, value);
                }).toList();

                print('Generated SpO2 spots: $spO2Spots');

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
                        // Date display container
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
                                          color:
                                              CustomTheme.textColorSecondary)),
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
                        ),
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
                  isCurved: true,
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
