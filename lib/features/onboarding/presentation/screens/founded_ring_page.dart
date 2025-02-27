import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/search_ring.dart';

class FoundedRingPage extends StatelessWidget {
  const FoundedRingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const GradientBackground(),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Founded Ring',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'These are the rings we found, please select one to connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Rings near you',
                    style: TextStyle(
                      color: Color.fromARGB(255, 118, 118, 118),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                // const SizedBox(height: 16),
                BlocBuilder<BluetoothBloc, BluetoothState>(
                  builder: (context, state) {
                    if (state is BluetoothScanning) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.devices.length,
                        itemBuilder: (context, index) {
                          final device = state.devices[index];
                          return ListTile(
                            title: Text(
                              device.name ?? 'Unknown Device',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              device.id,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onTap: () {
                              context.push('/connect_ring_page', extra: device);
                            },
                          );
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
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
}
