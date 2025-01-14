import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/ui/bluetooth/bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/ui/bluetooth/bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/ui/screens/onboarding/forms_screen.dart';
import 'package:health_ring_ai/ui/screens/onboarding/landing_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        // Get the PreferencesRepository instance
        final prefsRepository = context.read<PreferencesRepository>();

        return FutureBuilder<bool>(
          future: prefsRepository.isUserConnected,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final hasBeenFormScreen = snapshot.data ?? false;

            if (hasBeenFormScreen) {
              // User has completed forms, show main app screen
              return const FormsScreen(); // Create this screen
            } else {
              // User hasn't completed forms, show forms screen
              return const LandingPage();
            }
          },
        );
      },
    );
  }
}
