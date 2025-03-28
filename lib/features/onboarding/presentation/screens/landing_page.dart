import 'dart:ui'; // Required for the blur effect

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_event.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothBloc>().add(CheckBluetoothPermissions());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const GradientBackground(), // Background with blur effect
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Green glow behind the ring
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 1,
                        bottom: 1,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            boxShadow: [CustomTheme.ringGlow],
                          ),
                        ),
                      ),
                      const Image(
                        image: AssetImage(
                          'assets/png/ring.png',
                        ),
                        width: 163,
                        height: 187,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  "Let's begin by pairing\nyour Smart Ring",
                  textAlign: TextAlign.center,
                  style: CustomTheme.headerNormal,
                ),
                const SizedBox(height: 60),

                BlocBuilder<BluetoothBloc, BluetoothState>(
                  builder: (context, state) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: state is BluetoothLoading
                              ? null
                              : () async {
                                  context
                                      .read<BluetoothBloc>()
                                      .add(CheckBluetoothPermissions());

                                  if (state is BluetoothEnabled) {
                                    context.push("/onboarding_2");
                                  }
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: state is BluetoothLoading
                                  ? CustomTheme.primaryDefault.withOpacity(0.5)
                                  : CustomTheme.primaryDefault,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: state is BluetoothLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Begin',
                                    style: CustomTheme.buttonTextStyle,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'Please enable Bluetooth and Location permissions in settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BluetoothBloc>().add(OpenBluetoothSettings());
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showEnableBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Required'),
          content: const Text(
            'Please enable Bluetooth to continue pairing your Smart Ring.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BluetoothBloc>().add(EnableBluetooth());
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: CustomTheme.radialGradient, // Background gradient
          ),
        ),
        // Applying the blur effect using BackdropFilter
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur strength
          child: Container(
            color: Colors.black.withOpacity(0.1), // Semi-transparent overlay
          ),
        ),
      ],
    );
  }
}
