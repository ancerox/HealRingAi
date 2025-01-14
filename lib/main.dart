import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/routing/router.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_service.dart';
import 'package:health_ring_ai/ui/bluetooth/bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/ui/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BluetoothService>(
          create: (context) => BluetoothService(),
        ),
        RepositoryProvider<PreferencesRepository>(
          create: (context) => PreferencesRepository(prefs),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BluetoothBloc>(
            create: (context) => BluetoothBloc(
              bluetoothService: context.read<BluetoothService>(),
            ),
          ),
        ],
        child: MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          title: 'Health Ring AI',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
