import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';

import '../../../../core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_event.dart';

class ConnectRingPage extends StatefulWidget {
  final BluetoothDevice device;
  const ConnectRingPage({super.key, required this.device});

  @override
  _ConnectRingPageState createState() => _ConnectRingPageState();
}

class _ConnectRingPageState extends State<ConnectRingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isExpanding = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final BluetoothDevice device;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )
      ..addStatusListener((status) {
        // Add haptic feedback when animation changes direction
        if (status == AnimationStatus.forward) {
          isExpanding = true;
          HapticFeedback.lightImpact();
        } else if (status == AnimationStatus.reverse) {
          isExpanding = false;
          HapticFeedback.lightImpact();
        }
      })
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.3, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(), // Fondo con gradiente
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Icon(
                  Icons.bluetooth_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 40,
                ),
                Column(
                  children: [
                    Text("Found your device",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 10),
                    BlocBuilder<BluetoothBloc, BluetoothState>(
                      builder: (context, state) {
                        // Get the device name from the current state
                        String deviceName = widget.device.name;

                        if (state.devices?.isNotEmpty ?? false) {}

                        return Text(
                          deviceName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated GIF with gradual size changes
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _animation.value,
                          child: child,
                        );
                      },
                      child: const Image(
                        image: AssetImage('assets/gifs/ring_png.gif'),
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BlocBuilder<BluetoothBloc, BluetoothState>(
                        builder: (context, state) {
                          if (state is BluetoothConnected) {
                            // Add strong haptic feedback when connected
                            HapticFeedback.heavyImpact();
                            // Play custom sound
                            _audioPlayer
                                .play(AssetSource('sounds/success.mp3'));
                            Future.delayed(const Duration(milliseconds: 1000),
                                () {
                              if (mounted && context.mounted) {
                                context.go('/information_page');
                              }
                            });
                          }

                          return GlowingButton(
                            isLoading: state is BluetoothLoading,
                            onPressed: state is BluetoothLoading ||
                                    state is BluetoothConnected
                                ? null // This will disable the button when loading
                                : () {
                                    final bluetoothBloc =
                                        context.read<BluetoothBloc>();
                                    final device = widget.device;
                                    bluetoothBloc
                                        .add(ConnectToDevice(device: device));
                                  },
                            child: state is BluetoothLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  )
                                : state is BluetoothConnected
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TweenAnimationBuilder(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            tween:
                                                Tween<double>(begin: 0, end: 1),
                                            builder:
                                                (context, double value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.black,
                                                  size: 25,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Connect',
                                        style: TextStyle(fontSize: 15),
                                      ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/main');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: CustomTheme.primaryDefault),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'This is not my device',
                          style: TextStyle(
                              color: CustomTheme.primaryDefault, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reutilizando la clase del fondo con gradiente
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 9, 66, 65), // Cian brillante
            Color(0xFF102624), // Verde oscuro
            Color(0xFF131512),
            Color(0xFF111111), // Negro oscuro
            Color(0xFF111111), // Negro oscuro
          ],
        ),
      ),
    );
  }
}

class GlowingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GlowingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        bool showGlow =
            !(state is BluetoothConnected || state is BluetoothLoading);

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: showGlow
                    ? SweepGradient(
                        center: Alignment.center,
                        startAngle: 0,
                        endAngle: 2 * pi,
                        transform: GradientRotation(_animation.value),
                        colors: const [
                          Color.fromARGB(255, 198, 3, 252),
                          Colors.transparent,
                          Color.fromARGB(255, 3, 173, 252),
                          Colors.transparent,
                        ],
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(2), // Border width
              child: Container(
                decoration: BoxDecoration(
                  color: CustomTheme.primaryDefault,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.black,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: widget.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                      : widget.child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
