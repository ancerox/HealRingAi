import 'package:flutter/material.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/body_metrics_screen.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/home.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/sleep_data_screen.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/connect_ring_page.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/forms_screen.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/founded_ring_page.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/landing_page.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/search_ring.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LandingPage());

      case '/onboarding_2':
        return MaterialPageRoute(builder: (_) => const SmartRingSearchPage());

      case '/founded_ring_page':
        return MaterialPageRoute(
          builder: (_) => const FoundedRingPage(),
        );

      case '/connect_ring_page':
        return MaterialPageRoute(
          builder: (_) => ConnectRingPage(
            device: settings.arguments as BluetoothDevice,
          ),
        );

      case '/information_page':
        return MaterialPageRoute(builder: (_) => const FormsScreen());

      case '/body_metrics':
        return MaterialPageRoute(
            builder: (_) => BodyMetricsScreen(
                  dayIndex: settings.arguments as int,
                ));

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/sleep_data':
        return MaterialPageRoute(
          builder: (_) => SleepDataScreen(dayDiff: settings.arguments as int),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
