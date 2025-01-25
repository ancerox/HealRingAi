import 'package:flutter/material.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_platform_interface.dart';
import 'package:health_ring_ai/ui/screens/home.dart';
import 'package:health_ring_ai/ui/screens/home/body_metrics_screen.dart';
import 'package:health_ring_ai/ui/screens/home/sleep_data_screen.dart';
import 'package:health_ring_ai/ui/screens/onboarding/connect_ring_page.dart';
import 'package:health_ring_ai/ui/screens/onboarding/forms_screen.dart';
import 'package:health_ring_ai/ui/screens/onboarding/founded_ring_page.dart';
import 'package:health_ring_ai/ui/screens/onboarding/landing_page.dart';
import 'package:health_ring_ai/ui/screens/onboarding/search_ring.dart';

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
        return MaterialPageRoute(builder: (_) => const BodyMetricsScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/sleep_data':
        return MaterialPageRoute(builder: (_) => const SleepDataScreen());

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
