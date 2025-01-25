import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_service.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_event.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_state.dart';

class RingWaveAnimation extends StatefulWidget {
  const RingWaveAnimation({super.key});

  @override
  _RingWaveAnimationState createState() => _RingWaveAnimationState();
}

class _RingWaveAnimationState extends State<RingWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;

  final List<double> _waveRadii = [50, 100, 150]; // Track multiple wave radii

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: false);

    _timer = Timer.periodic(const Duration(milliseconds: 16), (Timer timer) {
      setState(() {
        // Update each wave radius
        for (int i = 0; i < _waveRadii.length; i++) {
          _waveRadii[i] += 1;
          // When a wave reaches max radius, reset it to start position and trigger haptic
          if (_waveRadii[i] > 200) {
            _waveRadii[i] = 50;
            // Double fast light haptic feedback
            HapticFeedback.lightImpact();
            Future.delayed(const Duration(milliseconds: 100), () {
              HapticFeedback.lightImpact();
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RingWavePainter(_waveRadii),
          child: const SizedBox(width: 400, height: 400),
        );
      },
    );
  }
}

class RingWavePainter extends CustomPainter {
  final List<double> radii;
  RingWavePainter(this.radii);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw each wave with its own radius and opacity
    for (int i = 0; i < radii.length; i++) {
      paint.color = Colors.white.withOpacity(1 - (radii[i] - 50) / 150);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radii[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SmartRingSearchPage extends StatefulWidget {
  const SmartRingSearchPage({super.key});

  @override
  State<SmartRingSearchPage> createState() => _SmartRingSearchPageState();
}

class SmartRingSearchPageBuilder extends StatelessWidget {
  const SmartRingSearchPageBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<BluetoothService>(
          create: (context) => BluetoothService(),
        ),
        BlocProvider<BluetoothBloc>(
          create: (context) => BluetoothBloc(
            bluetoothService: context.read<BluetoothService>(),
          ),
        ),
      ],
      child: const SmartRingSearchPage(),
    );
  }
}

class _SmartRingSearchPageState extends State<SmartRingSearchPage> {
  StreamSubscription? _bluetoothSubscription;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    final bluetoothBloc = context.read<BluetoothBloc>();

    // Start scanning
    bluetoothBloc.add(StartScanning());

    // Listen to the state changes and navigate when devices are found
    _bluetoothSubscription = bluetoothBloc.stream.listen((state) {
      if (state is BluetoothScanning && !_hasNavigated) {
        print('Found devices:');
        for (var device in state.devices) {
          print(
              'Device Name: ${device.name ?? "Unknown"}, ID: ${device.id}, RSSI: ${device.rssi}, Manufacturer Data: ${device.manufacturerData}');
        }
        if (state.devices.isNotEmpty) {
          _hasNavigated = true;
          // Add a delay of 2 seconds before navigation
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/founded_ring_page');
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _bluetoothSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              const GradientBackground(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 150),
                    Text(_getStatusText(state),
                        textAlign: TextAlign.center,
                        style: CustomTheme.headingStyle.copyWith(fontSize: 17)),
                    const SizedBox(height: 10),
                    Text(
                      'Please make sure that Bluetooth is enabled on your\nphone.',
                      textAlign: TextAlign.center,
                      style: CustomTheme.iosTextSmall,
                    ),
                    const SizedBox(height: 20),
                    // if (state is BluetoothScanning) ...[
                    //   // Display found devices
                    //   Expanded(
                    //     child: ListView.builder(
                    //       itemCount: state.devices.length,
                    //       itemBuilder: (context, index) {
                    //         final device = state.devices[index];
                    //         return ListTile(
                    //           title: Text(
                    //             device.name ?? 'Unknown Device',
                    //             style: CustomTheme.iosTextSmall,
                    //           ),
                    //           subtitle: Text(
                    //             device.id,
                    //             style: CustomTheme.iosTextSmall.copyWith(
                    //               color: Colors.grey,
                    //             ),
                    //           ),
                    //           onTap: () {
                    //             context
                    //                 .read<BluetoothBloc>()
                    //                 .add(ConnectToDevice(device: device));
                    //           },
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ],
                    const Spacer(),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 50,
                          bottom: 50,
                          child: Transform.rotate(
                            angle: 179.4 *
                                3.14159 /
                                180, // Convert degrees to radians
                            child: Container(
                              width: 47.362,
                              height: 18.712,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(
                                    9.356), // Half of height for ellipse

                                boxShadow: [CustomTheme.ringGlow],
                              ),
                            ),
                          ),
                        ),
                        // Adding ring glow effect behind the image
                        const Positioned(
                          child: SizedBox(
                            width: 163,
                            height: 163,
                            child:
                                RingWaveAnimation(), // Radiating wave animation
                          ),
                        ),
                        // Ring image on top
                        const Image(
                          image: AssetImage('assets/png/ring.png'),
                          width: 85,
                          height: 95,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Button to handle connection issues
                          TextButton(
                            onPressed: () {},
                            // style: TextButton.styleFrom(
                            //     side: CustomTheme.buttonBorderSide,
                            //     shape: CustomTheme.buttonShape,
                            //     minimumSize: const Size(240, 50)),
                            child: Text(
                              'Trouble connecting?',
                              style: CustomTheme.buttonTextStyle.copyWith(
                                  color: CustomTheme.primaryDefault,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(BluetoothState state) {
    if (state is BluetoothLoading) {
      return "Initializing Bluetooth...";
    } else if (state is BluetoothScanning) {
      return "Searching for your Ring...";
    } else if (state is BluetoothConnected) {
      return "Connected to ${state.device.name ?? 'Ring'}";
    } else if (state is BluetoothError) {
      return "Error: ${state.message}";
    } else if (state is BluetoothDisabled) {
      return "Please enable Bluetooth";
    } else if (state is BluetoothPermissionDenied) {
      return "Bluetooth permission required";
    }
    return "Searching for your Ring...";
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CustomTheme.primaryDefault.withOpacity(0.1),
                  CustomTheme.primaryDefault.withOpacity(0.14),
                  CustomTheme.primaryDefault.withOpacity(0.1),
                  CustomTheme.primaryDefault.withOpacity(0.05),
                  CustomTheme.black.withOpacity(0.05),
                ],
              ),
            ),
            width: double.infinity,
            height: 600,
          ),
        ),
      ],
    );
  }
}
