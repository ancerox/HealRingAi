import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/ui/bluetooth/bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/ui/bluetooth/bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/ui/screens/home.dart';
import 'package:health_ring_ai/ui/screens/onboarding/forms_screen.dart';
import 'package:health_ring_ai/ui/screens/onboarding/landing_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        final prefsRepository = context.read<PreferencesRepository>();

        return FutureBuilder<bool>(
          future: prefsRepository.isUserConnected,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final hasBeenFormScreen = snapshot.data ?? false;

            if (hasBeenFormScreen) {
              // Show main app with bottom nav
              return const MainAppScaffold(
                showBottomNav: false,
                child: FormsScreen(),
              );
            } else {
              // Hide bottom nav during onboarding
              return const MainAppScaffold(
                showBottomNav: false,
                child: LandingPage(),
              );
            }
          },
        );
      },
    );
  }
}

class MainAppScaffold extends StatefulWidget {
  final Widget child;
  final bool showBottomNav;

  const MainAppScaffold({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Placeholder(), // Lifespan screen
    const Placeholder(), // AI Chat screen
    const Placeholder(), // Profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: widget.child,
        bottomNavigationBar: widget.showBottomNav
            ? Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: CustomTheme.surfacePrimary,
                      width: 0.5,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.black,
                  selectedItemColor: CustomTheme.primaryDefault,
                  unselectedItemColor: Colors.grey,
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/svg/activity_heart.svg',
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 0
                              ? CustomTheme.primaryDefault
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'Health',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/svg/calendar-heart-01.svg',
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 1
                              ? CustomTheme.primaryDefault
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'Lifespan',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/svg/Messages.svg',
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 2
                              ? CustomTheme.primaryDefault
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'AI Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/svg/Profile.svg',
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 3
                              ? CustomTheme.primaryDefault
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
