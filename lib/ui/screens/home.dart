import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooh_interaction_bloc/bloc/bluethooth_interactions_bloc.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/ui/screens/app.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  late ScrollController _scrollController;
  final List<DateTime> _dates = [];
  DateTime _selectedDate = DateTime.now();
  final bool _isConnectedHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/watter_fall.mov')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
    _scrollController = ScrollController();

    // Generate dates for the calendar (2 weeks before and after today)
    final now = DateTime.now();
    for (int i = -14; i <= 14; i++) {
      _dates.add(now.add(Duration(days: i)));
    }

    // Initial data fetch for today (day difference = 0)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluethoothInteractionsBloc>().add(
            const GetHeartRateData(dayIndices: [0]),
          );

      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 70.0;
      final offset = (14 * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Add method to calculate day difference
  int _calculateDayDifference(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return today.difference(selected).inDays;
  }

  // Update calendar picker with day difference handling
  Widget _buildCalendarPicker() {
    final now = DateTime.now();

    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isToday = DateUtils.isSameDay(date, now);
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isBeforeSelected = date.isBefore(DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day));

          // Dynamic color selection logic
          Color containerColor;
          if (isSelected) {
            containerColor = CustomTheme.surfacePrimary;
          } else if (isBeforeSelected) {
            containerColor = CustomTheme.surfaceTertiary;
          } else {
            containerColor = CustomTheme.surfaceSecondary;
          }

          return GestureDetector(
            onTap: date.isAfter(now.add(const Duration(days: 0)))
                ? null
                : () {
                    setState(() {
                      _selectedDate = date;
                    });

                    // Calculate day difference and request data
                    final dayDiff = _calculateDayDifference(date);
                    print('Selected date: $date, Day difference: $dayDiff');

                    context.read<BluethoothInteractionsBloc>().add(
                          GetHeartRateData(dayIndices: [dayDiff]),
                        );
                  },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEE').format(date),
                    style: TextStyle(
                      color:
                          date.isAfter(now) ? Colors.grey[600] : Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color:
                          date.isAfter(now) ? Colors.grey[600] : Colors.white,
                      fontSize: 20,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Update refresh method to use selected date
  Future<void> _onRefresh() async {
    final dayDiff = _calculateDayDifference(_selectedDate);
    context.read<BluethoothInteractionsBloc>().add(
          GetHeartRateData(dayIndices: [dayDiff]),
        );
    await Future.delayed(const Duration(seconds: 1));
  }

  // Add this new method to build health metric cards
  Widget _buildHealthMetricCard({
    required String icon,
    required String value,
    required String label,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceSecondary,
        border: Border.all(
          color: CustomTheme.surfacePrimary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: CustomTheme.surfaceTertiary,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/svg/$icon',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                status == 'Normal'
                    ? Icon(
                        Icons.check_circle,
                        color: statusColor,
                        size: 16,
                      )
                    : Transform.rotate(
                        angle: -90 *
                            3.14159 /
                            180, // Rotate -90 degrees to point up
                        child: Icon(
                          Icons.double_arrow,
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainAppScaffold(
      showBottomNav: true,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: CustomTheme.primaryDefault, // Match your app's theme
        backgroundColor: CustomTheme.surfaceSecondary,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator to work
          child: Column(
            children: [
              Stack(
                children: [
                  // Video and shader mask
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          0.9,
                          0.9,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Container(
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: _controller.value.isInitialized
                            ? FittedBox(
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, 1.0),
                                child: SizedBox(
                                  width: _controller.value.size.width,
                                  height: _controller.value.size.height,
                                  child: VideoPlayer(_controller),
                                ),
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  // Health Metrics text
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Health Metrics',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildCalendarPicker(),
              const SizedBox(height: 20),
              // Add Body Metrics section
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/body_metrics',
                  );
                },
                child: Container(
                  // margin: const EdgeInsets.all(16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  // decoration: BoxDecoration(
                  //   color: CustomTheme.calendarPastDay, // Using existing dark color
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Body Metrics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Measured every 15 minutes',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
              BlocListener<BluetoothBloc, BluetoothState>(
                // listenWhen: (previous, current) {
                //   // Only trigger when transitioning to connected state
                //   return current is BluetoothConnected &&
                //       (previous is! BluetoothConnected ||
                //           (previous).device.id != current.device.id);
                // },
                listener: (context, state) {
                  if (state is BluetoothConnected && !_isConnectedHandled) {
                    print('BluetoothConnected to test $state');
                  }
                  // if (state is BluetoothConnected) {
                  //   context.read<BluethoothInteractionsBloc>().add(
                  //         const GetHeartRateData(dayIndices: [0]),
                  //       );
                  // }
                },
                child: BlocBuilder<BluethoothInteractionsBloc,
                    BluethoothInteractionsState>(
                  builder: (context, state) {
                    print('BluethoothInteractionsState: $state');
                    // Show loading state
                    if (state is! HeartRateDataReceived) {
                      return Column(
                        children: [
                          _buildHealthMetricCard(
                            icon: 'activity_heart.svg',
                            value: '--:--',
                            label: 'Heart rate',
                            status: 'Loading...',
                            statusColor: Colors.grey,
                          ),
                          // const SizedBox(height: 16),
                          _buildHealthMetricCard(
                            icon: 'activity.svg',
                            value: '--:--',
                            label: 'Blood Oxygen',
                            status: 'Loading...',
                            statusColor: Colors.grey,
                          ),
                        ],
                      );
                    }

                    // Show no data state if lists are empty
                    if (state.combinedHealthData.heartRateData.isEmpty ||
                        state.combinedHealthData.bloodOxygenData.isEmpty) {
                      return Column(
                        children: [
                          _buildHealthMetricCard(
                            icon: 'activity_heart.svg',
                            value: '--:--',
                            label: 'Heart rate',
                            status: 'No data',
                            statusColor: Colors.grey,
                          ),
                          // const SizedBox(height: 16),
                          _buildHealthMetricCard(
                            icon: 'activity.svg',
                            value: '--:--',
                            label: 'Blood Oxygen',
                            status: 'No data',
                            statusColor: Colors.grey,
                          ),
                        ],
                      );
                    }

                    // Process data when available
                    final nonZeroHeartRates = state
                        .combinedHealthData.heartRateData.first.heartRates
                        .where((rate) => rate > 0)
                        .toList();
                    final avgHeartRate = nonZeroHeartRates.isEmpty
                        ? null
                        : nonZeroHeartRates.reduce((a, b) => a + b) /
                            nonZeroHeartRates.length;

                    // Calculate average SpO2 from valid readings
                    final validSpO2Readings = state
                        .combinedHealthData.bloodOxygenData
                        .where((data) => data.bloodOxygenLevels.first > 0)
                        .map((data) => data.bloodOxygenLevels.first)
                        .toList();

                    final avgSpO2 = validSpO2Readings.isEmpty
                        ? null
                        : validSpO2Readings.reduce((a, b) => a + b) /
                            validSpO2Readings.length;

                    return Column(
                      children: [
                        _buildHealthMetricCard(
                          icon: 'activity_heart.svg',
                          value: avgHeartRate == null
                              ? '--:--'
                              : '${avgHeartRate.round()} bpm',
                          label: 'Heart rate',
                          status: avgHeartRate == null
                              ? 'No data'
                              : avgHeartRate > 100
                                  ? 'Very Elevated'
                                  : avgHeartRate > 85
                                      ? 'Elevated'
                                      : avgHeartRate > 60
                                          ? 'Normal'
                                          : 'Low',
                          statusColor: avgHeartRate == null
                              ? Colors.grey
                              : avgHeartRate > 100
                                  ? Colors.red
                                  : avgHeartRate > 85
                                      ? Colors.orange
                                      : avgHeartRate > 60
                                          ? Colors.green
                                          : Colors.blue,
                        ),
                        // const SizedBox(height: 16),
                        _buildHealthMetricCard(
                          icon: 'activity.svg',
                          value: avgSpO2 == null
                              ? '--:--'
                              : '${avgSpO2.toStringAsFixed(1)}%',
                          label: 'Blood Oxygen',
                          status: avgSpO2 == null
                              ? 'No data'
                              : avgSpO2 > 95
                                  ? 'Normal'
                                  : avgSpO2 > 90
                                      ? 'Low'
                                      : 'Very Low',
                          statusColor: avgSpO2 == null
                              ? Colors.grey
                              : avgSpO2 > 95
                                  ? Colors.green
                                  : avgSpO2 > 90
                                      ? Colors.orange
                                      : Colors.red,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 0.5,
                color: CustomTheme.surfacePrimary,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/sleep_data',
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sleep',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Measured during your sleep',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  _buildHealthMetricCard(
                    icon: 'moon-star.svg',
                    value: '8h 25min',
                    label: 'Sleep duration',
                    status: 'Excellent',
                    statusColor: Colors.teal,
                  ),
                  _buildHealthMetricCard(
                    icon: 'activity_heart.svg',
                    value: '42 ms',
                    label: 'Heart rate variability',
                    status: 'Very Low',
                    statusColor: Colors.red,
                  ),
                  _buildHealthMetricCard(
                    icon: 'activity_heart.svg',
                    value: '51 bpm',
                    label: 'Resting heart rate',
                    status: 'Normal',
                    statusColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
