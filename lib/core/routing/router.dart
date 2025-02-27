import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/app.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/ai_chat_speech_screen.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/body_metrics_screen.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/home.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/home/sleep_data_screen.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/checking_vitrals_screen.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/connect_ring_page.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/forms_screen.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/founded_ring_page.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/search_ring.dart';
import 'package:health_ring_ai/features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigationKey = GlobalKey<NavigatorState>();
  static final _rootNavigationHomeKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigationKey,
    routes: [
      GoRoute(
        path: '/',
        name: 'AuthWrapper',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/onboarding_2',
        name: 'SmartRingSearchPage',
        builder: (context, state) => const SmartRingSearchPage(),
      ),
      GoRoute(
        path: '/founded_ring_page',
        name: 'FoundedRingPage',
        builder: (context, state) => const FoundedRingPage(),
      ),
      GoRoute(
        path: '/connect_ring_page',
        name: 'ConnectRingPage',
        builder: (context, state) => ConnectRingPage(
          device: state.extra as BluetoothDevice,
        ),
      ),
      GoRoute(
        path: '/information_page',
        name: 'FormsScreen',
        builder: (context, state) => const FormsScreen(),
      ),
      GoRoute(
          path: '/checking_vitals',
          name: 'CheckingVitals',
          builder: (context, state) => const CheckingVitralsScreen()),
      GoRoute(
        path: '/body_metrics',
        name: 'BodyMetricsScreen',
        builder: (context, state) => BodyMetricsScreen(
          dayIndex: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/ai-chat-speech',
        name: 'AiChatSpeechScreen',
        builder: (context, state) => const AiChatSpeechScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            statefulNavigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _rootNavigationHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'HomeScreen',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lifespan',
                name: 'LifespanScreen',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ShellRoute(
                builder: (context, state, child) => child,
                routes: [
                  GoRoute(
                    path: '/ai-chat',
                    name: 'AiChatScreen',
                    builder: (context, state) => const AiChatScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'ProfileScreen',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/sleep_data',
        name: 'SleepDataScreen',
        builder: (context, state) => SleepDataScreen(
          dayDiff: state.extra as int,
        ),
      ),
    ],
  );
}
