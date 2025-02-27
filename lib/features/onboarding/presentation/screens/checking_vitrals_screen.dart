import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/ring_connection/data/bluetooth_service.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/blood_oxygen_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/combined_health_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/heart_rate_data.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/connect_ring_page.dart';
import 'package:hive/hive.dart';

class CheckingVitralsScreen extends StatefulWidget {
  const CheckingVitralsScreen({super.key});

  @override
  State<CheckingVitralsScreen> createState() => _CheckingVitralsScreenState();
}

class _CheckingVitralsScreenState extends State<CheckingVitralsScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late AnimationController _circleController;
  late Animation<double> _circleFadeAnimation;
  late AudioPlayer _player;
  final BluetoothService bluetoothService = BluetoothService();
  int _measurementPercentage = 0;
  Timer? _percentageTimer;
  bool _showCircle = false;
  late AnimationController _textController;
  late Animation<Offset> _textPositionAnimation;
  int _heartRate = 0;
  bool _showBloodOxygenMessage = false;
  late AnimationController _typewriterController;
  late Animation<int> _typewriterAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonFadeAnimation;
  bool _showContinueButton = false;

  int heartRateBeat = 0;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeAnimationControllers();
    _initializeAnimations();
    _startInitialSequence();
    _startMeasurements();
  }

  void _initializeAudio() {
    _player = AudioPlayer();
    _player.play(AssetSource('sounds/calm.FLAC'));
  }

  void _initializeAnimationControllers() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(_handleTextControllerUpdate);

    _typewriterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(_handleTypewriterUpdate);

    _buttonAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _circleFadeAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeIn,
    );

    _textPositionAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _typewriterAnimation = IntTween(
      begin: 0,
      end: "Measuring your blood oxygen...".length,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeIn,
    ));

    _buttonFadeAnimation = CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutQuart,
    );
  }

  void _startInitialSequence() {
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      _startPercentageTimer();
    });
  }

  void _handleTextControllerUpdate() {
    if (_textController.value >= 0.5 && _textController.value < 0.51) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTypewriterUpdate() {
    final currentChar = _typewriterAnimation.value;
    int previousChar = 0;

    if (currentChar > previousChar) {
      HapticFeedback.lightImpact();
      previousChar = currentChar;
    }
  }

  void _handleHeartRateData(int heartRate) {
    setState(() {
      _showCircle = true;
      _heartRate = heartRate;
    });
    _circleController.forward();
    _textController.forward();
    _startBloodOxygenSequence();
  }

  void _startBloodOxygenSequence() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showBloodOxygenMessage = true;
      });
      _typewriterController.forward().then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          _typewriterController.reverse().then((_) {
            setState(() {
              _showBloodOxygenMessage = false;
            });
          });
        });
      });
    });
  }

  void _startMeasurements() {
    bluetoothService.startMeasurement(1).listen((data) {
      if (data['dataType'] == 'heartRate') {
        _handleHeartRateData(data['value']);
      } else if (data['dataType'] == 'bloodOxygen') {
        final now = DateTime.now().millisecondsSinceEpoch / 1000.0;

        final combinedData = CombinedHealthData(heartRateData: [
          HeartRateData(
            date: DateTime.now().toString().substring(0, 10),
            heartRates: [_heartRate],
            secondInterval: 300,
            deviceId: '',
            deviceType: '',
          ),
        ], bloodOxygenData: [
          BloodOxygenData(
            date: now,
            bloodOxygenLevels: [data['value'].toDouble()],
            secondInterval: 0,
            deviceId: '',
            deviceType: '',
          ),
        ]);

        final box = Hive.box('bluetooth_cache');
        const key = 'health_data_0';
        box.put(key, combinedData.toJson());

        _completeMeasurement();
      } else if (data['dataType'] == 'error') {
        _handleMeasurementError(data['message']);
      }
    }, onError: (error) {
      _handleMeasurementError(error.toString());
    });
  }

  void _startPercentageTimer() {
    _percentageTimer =
        Timer.periodic(const Duration(milliseconds: 640), (timer) {
      if (_measurementPercentage < 100) {
        setState(() {
          _measurementPercentage += 1;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _completeMeasurement() {
    setState(() {
      _measurementPercentage = 100;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _showContinueButton = true;
      });
      _buttonAnimationController.forward();
    });
  }

  void _handleMeasurementError(String message) {
    _percentageTimer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Measurement Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    _circleController.dispose();
    _textController.dispose();
    _percentageTimer?.cancel();
    _typewriterController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.black,
      body: Stack(
        children: [
          const GradientBackground(),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeader(),
          _buildVisualization(),
          _buildProgressSection(),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: const Text(
        "Checking your vitals...",
        style: CustomTheme.headerLarge,
      ),
    );
  }

  Widget _buildVisualization() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          const SizedBox.expand(
            child: ECGAnimation(),
          ),
          if (_showCircle)
            FadeTransition(
              opacity: _circleFadeAnimation,
              child: Center(
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomTheme.primaryDefault,
                          width: 2,
                        ),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: SlideTransition(
                          position: _textPositionAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "HeartRate",
                                style: CustomTheme.headerLarge
                                    .copyWith(fontSize: 20),
                              ),
                              Text(
                                "$_heartRate bpm",
                                style: CustomTheme.textNormal
                                    .copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          if (_showBloodOxygenMessage)
            AnimatedBuilder(
              animation: _typewriterAnimation,
              builder: (context, child) {
                const text = "Measuring your blood oxygen...";
                return Text(
                  text.substring(0, _typewriterAnimation.value),
                  style: CustomTheme.headerLarge,
                );
              },
            )
          else
            Text(
              "Measuring $_measurementPercentage%",
              style: CustomTheme.headerLarge,
            ),
          const Text(
            "Stay still while we measure\nyour heart rate and\noxygen levels",
            textAlign: TextAlign.center,
            style: CustomTheme.textNormal,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return _showContinueButton
        ? FadeTransition(
            opacity: _buttonFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Transform.translate(
                offset: Tween<Offset>(
                  begin: const Offset(0, 20),
                  end: Offset.zero,
                )
                    .animate(CurvedAnimation(
                      parent: _buttonAnimationController,
                      curve: Curves.easeOutQuart,
                    ))
                    .value,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryDefault,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor:
                        CustomTheme.primaryDefault.withOpacity(0.5),
                  ),
                  onPressed: () {
                    GoRouter.of(context).pushReplacement('/home');
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          );
  }
}

class ECGAnimation extends StatefulWidget {
  const ECGAnimation({super.key});

  @override
  _ECGAnimationState createState() => _ECGAnimationState();
}

class _ECGAnimationState extends State<ECGAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ECGPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

class ECGPainter extends CustomPainter {
  final double animationValue;

  ECGPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint ecgPaint = Paint()
      ..color = CustomTheme.primaryDefault
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path ecgPath = Path();
    final double centerY = size.height / 2;
    final double amplitudeFactor = size.height * 0.2;

    for (double x = 0; x <= size.width; x++) {
      double t = (x / size.width + animationValue) % 1.0;
      double ecgValue = _ecgWave(t);
      double y = centerY - ecgValue * amplitudeFactor;
      if (x == 0) {
        ecgPath.moveTo(x, y);
      } else {
        ecgPath.lineTo(x, y);
      }
    }

    canvas.drawPath(ecgPath, ecgPaint);
  }

  double _ecgWave(double t) {
    t = t % 0.5;

    if (t < 0.1) {
      return 0;
    } else if (t < 0.15) {
      double progress = (t - 0.1) / 0.05;
      return lerpDouble(0, -0.5, progress)!;
    } else if (t < 0.25) {
      double progress = (t - 0.15) / 0.1;
      return lerpDouble(-0.5, 1.0, progress)!;
    } else if (t < 0.3) {
      double progress = (t - 0.25) / 0.05;
      return lerpDouble(1.0, -1.2, progress)!;
    } else if (t < 0.4) {
      double progress = (t - 0.3) / 0.1;
      return lerpDouble(-1.2, 0, progress)!;
    } else {
      return 0;
    }
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
