import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/app.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/ring_connection/data/bluetooth_service.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/routing/router.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/continuous_monitoring_bloc/bloc/continuous_monitoring_bloc.dart';
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
          BlocProvider<ContinuousMonitoringBloc>(
            create: (context) => ContinuousMonitoringBloc(
              bluetoothBloc: context.read<BluetoothBloc>(),
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
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
