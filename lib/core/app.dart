import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/onboarding/presentation/onboarding/landing_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<Map<String, bool>> _preferencesFuture;

  @override
  void initState() {
    super.initState();
    _preferencesFuture = _loadPreferences();
  }

  Future<Map<String, bool>> _loadPreferences() async {
    final prefsRepository = context.read<PreferencesRepository>();
    return {
      'hasBeenFormScreen': await prefsRepository.isUserConnected,
      'isFirstLaunch': await prefsRepository.isFirstLaunch,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _preferencesFuture,
      builder: (context, snapshot) {
        // 1. While loading, show a progress indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Once the future has data
        final isFirstLaunch = snapshot.data?['isFirstLaunch'] ?? true;
        final hasBeenFormScreen = snapshot.data?['hasBeenFormScreen'] ?? false;

        // If we *know* we should send them directly to home or info,
        // navigate immediately and return a placeholder so we never see LandingPage.
        if (!isFirstLaunch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
          return const SizedBox.shrink(); // invisible placeholder
        } else if (hasBeenFormScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/information_page');
          });
          return const SizedBox.shrink();
        }

        // Otherwise, show the LandingPage
        return const LandingPage();
      },
    );
  }
}

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell statefulNavigationShell;

  const MainWrapper({super.key, required this.statefulNavigationShell});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // final List<Widget> _screens = [
  //   const HomeScreen(),
  //   const Placeholder(), // Lifespan screen
  //   const AiChatScreen(), // AI Chat screen
  //   const Placeholder(), // Profile screen
  // ];
  void _goToBranch(int index) {
    widget.statefulNavigationShell.goBranch(
      index,
      initialLocation: index == widget.statefulNavigationShell.currentIndex,
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          body: widget.statefulNavigationShell,
          bottomNavigationBar: Container(
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
                _goToBranch(_selectedIndex);
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
          )),
    );
  }
}
