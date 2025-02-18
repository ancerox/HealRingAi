import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/continuous_monitoring_bloc/bloc/continuous_monitoring_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
    _startVideo();
    _initialHomeData();

    // Initial data fetch for today (day difference = 0)
  }

  void _initialHomeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ContinuousMonitoringBloc>().add(
            GetBatteryLevel(),
          );

      final prefsRepository = context.read<PreferencesRepository>();

      if (await prefsRepository.isFirstLaunch) {}
    });
  }

  void _startVideo() {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  // Update calendar picker with day difference handling

  // Add this new method to build health metric cards

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothBloc, BluetoothState>(
      listener: (context, state) {
        if (state is BluetoothConnected && !_isConnectedHandled) {
          context.read<ContinuousMonitoringBloc>().add(GetBatteryLevel());
        }
      },
      child:
          BlocListener<ContinuousMonitoringBloc, BluethoothInteractionsState>(
        listener: (context, state) {
          if (state is BatteryLevelReceived) {
            context.read<ContinuousMonitoringBloc>().add(
                  const GetHomeData(dayIndex: 0),
                );
          }
        },
        child: Scaffold(
          backgroundColor: CustomTheme.black,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: CustomTheme.primaryDefault,
            backgroundColor: CustomTheme.surfaceSecondary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Video and shader mask
                      videoView(),
                      // Health Metrics text
                      _healthTitle(),
                    ],
                  ),
                  BlocBuilder<ContinuousMonitoringBloc,
                      BluethoothInteractionsState>(
                    buildWhen: (previous, current) {
                      return current is BatteryLevelReceived ||
                          current is BatteryLevelLoading ||
                          current is BatteryLevelError;
                    },
                    builder: (context, state) {
                      if (state is BatteryLevelReceived) {
                        return _batteryWidget(state);
                      }
                      return const Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            "Read battery failed",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      );
                    },
                  ),
                  _buildCalendarPicker(),
                  const SizedBox(height: 20),
                  // Add Body Metrics section
                  BlocBuilder<ContinuousMonitoringBloc,
                      BluethoothInteractionsState>(
                    buildWhen: (previous, current) {
                      // Rebuild for any HomeData-related state changes
                      return current is HomeDataRecevied ||
                          current is HomeDataLoading ||
                          current is HomeDataError;
                    },
                    builder: (context, state) {
                      // Build the Body Metrics section
                      Widget bodyMetricsSection;
                      if (state is HomeDataLoading) {
                        bodyMetricsSection = const Column(
                          children: [
                            LoadingShimmerCard(),
                            LoadingShimmerCard(),
                          ],
                        );
                      } else if (state is HomeDataRecevied) {
                        bodyMetricsSection = Column(
                          children: [
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: state.avgHeartRate == null
                                  ? '--:--'
                                  : '${state.avgHeartRate!.round()} bpm',
                              label: 'Heart rate',
                              status: _getHeartRateStatus(state.avgHeartRate),
                              statusColor:
                                  _getHeartRateColor(state.avgHeartRate),
                            ),
                            _buildHealthMetricCard(
                              icon: 'activity.svg',
                              value: state.avgSpO2 == null
                                  ? '--:--'
                                  : '${state.avgSpO2!.toStringAsFixed(1)}%',
                              label: 'Blood Oxygen',
                              status: _getSpO2Status(state.avgSpO2),
                              statusColor: _getSpO2Color(state.avgSpO2),
                            ),
                          ],
                        );
                      } else if (state is HomeDataError) {
                        bodyMetricsSection = Column(
                          children: [
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: 'Error',
                              label: 'Heart rate',
                              status: 'Error',
                              statusColor: Colors.red,
                            ),
                            _buildHealthMetricCard(
                              icon: 'activity.svg',
                              value: 'Error',
                              label: 'Blood Oxygen',
                              status: 'Error',
                              statusColor: Colors.red,
                            ),
                          ],
                        );
                      } else {
                        bodyMetricsSection = Column(
                          children: [
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: '--:--',
                              label: 'Heart rate',
                              status: 'No data',
                              statusColor: Colors.grey,
                            ),
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

                      // Build the Sleep section
                      Widget sleepSection;
                      if (state is HomeDataLoading) {
                        sleepSection = const Column(
                          children: [
                            LoadingShimmerCard(),
                            LoadingShimmerCard(),
                            LoadingShimmerCard(),
                          ],
                        );
                      } else if (state is HomeDataRecevied) {
                        if (state.sleepData.isEmpty) {
                          sleepSection = Column(
                            children: [
                              _buildHealthMetricCard(
                                icon: 'moon-star.svg',
                                value: 'No data',
                                label: 'Sleep duration',
                                status: 'No data',
                                statusColor: Colors.grey,
                              ),
                              _buildHealthMetricCard(
                                icon: 'activity_heart.svg',
                                value: 'No data',
                                label: 'Heart rate variability',
                                status: 'No data',
                                statusColor: Colors.grey,
                              ),
                              _buildHealthMetricCard(
                                icon: 'activity_heart.svg',
                                value: 'No data',
                                label: 'Resting heart rate',
                                status: 'No data',
                                statusColor: Colors.grey,
                              ),
                            ],
                          );
                        } else {
                          sleepSection = Column(
                            children: [
                              _buildHealthMetricCard(
                                icon: 'moon-star.svg',
                                value:
                                    '${state.totalSleepMinutes ~/ 60}h ${state.totalSleepMinutes % 60}min',
                                label: 'Sleep duration',
                                status: state.totalSleepMinutes >= 420
                                    ? 'Excellent'
                                    : state.totalSleepMinutes >= 360
                                        ? 'Good'
                                        : 'Poor',
                                statusColor: state.totalSleepMinutes >= 420
                                    ? Colors.green
                                    : state.totalSleepMinutes >= 360
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              _buildHealthMetricCard(
                                icon: 'moon-star.svg',
                                value:
                                    '${state.deepSleepMinutes ~/ 60}h ${state.deepSleepMinutes % 60}min',
                                label: 'Deep sleep',
                                status: state.deepSleepMinutes >= 90
                                    ? 'Good'
                                    : state.deepSleepMinutes >= 60
                                        ? 'Fair'
                                        : 'Poor',
                                statusColor: state.deepSleepMinutes >= 90
                                    ? Colors.green
                                    : state.deepSleepMinutes >= 60
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              _buildHealthMetricCard(
                                icon: 'moon-star.svg',
                                value:
                                    '${state.lightSleepMinutes ~/ 60}h ${state.lightSleepMinutes % 60}min',
                                label: 'Light sleep',
                                status: state.lightSleepMinutes >= 240
                                    ? 'Good'
                                    : state.lightSleepMinutes >= 180
                                        ? 'Fair'
                                        : 'Poor',
                                statusColor: state.lightSleepMinutes >= 240
                                    ? Colors.green
                                    : state.lightSleepMinutes >= 180
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              _buildHealthMetricCard(
                                icon: 'activity_heart.svg',
                                value:
                                    '${state.awakeSleepMinutes ~/ 60}h ${state.awakeSleepMinutes % 60}min',
                                label: 'Awake time',
                                status: state.awakeSleepMinutes <= 30
                                    ? 'Good'
                                    : 'Fair',
                                statusColor: state.awakeSleepMinutes <= 30
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          );
                        }
                      } else if (state is HomeDataError) {
                        sleepSection = Column(
                          children: [
                            _buildHealthMetricCard(
                              icon: 'moon-star.svg',
                              value: 'Error',
                              label: 'Sleep duration',
                              status: 'Error',
                              statusColor: Colors.red,
                            ),
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: 'Error',
                              label: 'Heart rate variability',
                              status: 'Error',
                              statusColor: Colors.red,
                            ),
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: 'Error',
                              label: 'Resting heart rate',
                              status: 'Error',
                              statusColor: Colors.red,
                            ),
                          ],
                        );
                      } else {
                        sleepSection = Column(
                          children: [
                            _buildHealthMetricCard(
                              icon: 'moon-star.svg',
                              value: '--:--',
                              label: 'Sleep duration',
                              status: 'No data',
                              statusColor: Colors.grey,
                            ),
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: '--:--',
                              label: 'Heart rate variability',
                              status: 'No data',
                              statusColor: Colors.grey,
                            ),
                            _buildHealthMetricCard(
                              icon: 'activity_heart.svg',
                              value: '--:--',
                              label: 'Resting heart rate',
                              status: 'No data',
                              statusColor: Colors.grey,
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          // Body Metrics header and content
                          InkWell(
                            onTap: state is HomeDataRecevied &&
                                    state.combinedHealthData.bloodOxygenData
                                        .isNotEmpty &&
                                    state.combinedHealthData.heartRateData
                                        .isNotEmpty
                                ? () {
                                    context.pushNamed("BodyMetricsScreen",
                                        extra: _calculateDayDifference(
                                            _selectedDate));
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          bodyMetricsSection,
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 0.5,
                            color: CustomTheme.surfacePrimary,
                          ),
                          // Sleep header and content
                          InkWell(
                            onTap: state is HomeDataRecevied &&
                                    state.sleepData.isNotEmpty
                                ? () {
                                    context.push('/sleep_data',
                                        extra: _calculateDayDifference(
                                            _selectedDate));
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          sleepSection,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _batteryWidget(BatteryLevelReceived state) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.battery_full,
                color: _getBatteryColor(state.batteryLevel),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.batteryLevel}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Positioned _healthTitle() {
    return Positioned(
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
    );
  }

  ShaderMask videoView() {
    return ShaderMask(
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
    );
  }

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

                    final dayDiff = _calculateDayDifference(date);

                    context.read<ContinuousMonitoringBloc>().add(
                          GetHomeData(dayIndex: dayDiff),
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

  // Update the day difference calculation method
  int _calculateDayDifference(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Only allow past dates
    final difference = today.difference(selected).inDays;
    return difference.clamp(0, 365); // 0 = today, 365 = max 1 year back
  }

  // Update refresh method to use selected date
  Future<void> _onRefresh() async {
    final dayDiff = _calculateDayDifference(_selectedDate);
    context.read<ContinuousMonitoringBloc>().add(
          GetHeartRateData(dayIndices: [dayDiff]),
        );
    // context.read<BluethoothInteractionsBloc>().add(
    //       GetSleepData(dayDiff),
    //     );
    await Future.delayed(const Duration(seconds: 1));
  }

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

  Color _getBatteryColor(int level) {
    if (level <= 2) return Colors.red;
    if (level <= 4) return Colors.orange;
    return Colors.green;
  }

  String _getHeartRateStatus(double? avgHeartRate) {
    if (avgHeartRate == null) {
      return 'No data';
    } else if (avgHeartRate > 100) {
      return 'Very Elevated';
    } else if (avgHeartRate > 85) {
      return 'Elevated';
    } else if (avgHeartRate > 60) {
      return 'Normal';
    } else {
      return 'Low';
    }
  }

  Color _getHeartRateColor(double? avgHeartRate) {
    if (avgHeartRate == null) {
      return Colors.grey;
    } else if (avgHeartRate > 100) {
      return Colors.red;
    } else if (avgHeartRate > 85) {
      return Colors.orange;
    } else if (avgHeartRate > 60) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  String _getSpO2Status(double? avgSpO2) {
    if (avgSpO2 == null) {
      return 'No data';
    } else if (avgSpO2 > 95) {
      return 'Normal';
    } else if (avgSpO2 > 90) {
      return 'Low';
    } else {
      return 'Very Low';
    }
  }

  Color _getSpO2Color(double? avgSpO2) {
    if (avgSpO2 == null) {
      return Colors.grey;
    } else if (avgSpO2 > 95) {
      return Colors.green;
    } else if (avgSpO2 > 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class LoadingShimmerCard extends StatelessWidget {
  const LoadingShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CustomTheme.surfaceSecondary,
      highlightColor: const Color.fromARGB(255, 37, 37, 37),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
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
}
