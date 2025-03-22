import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/ring_connection/data/bluetooth_service.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/routing/router.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/blood_oxygen_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/combined_health_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/heart_rate_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/sleep_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/presentation/continuous_monitoring_bloc/bloc/continuous_monitoring_bloc.dart';
import 'package:health_ring_ai/injection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(CombinedHealthDataAdapter());
  Hive.registerAdapter(HeartRateDataAdapter());
  Hive.registerAdapter(BloodOxygenDataAdapter());
  Hive.registerAdapter(SleepDataAdapter());

  await Hive.openBox('bluetooth_cache');
  await init();

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
            lazy: true,
            create: (context) => ContinuousMonitoringBloc(
              bluetoothBloc: context.read<BluetoothBloc>(),
              bluetoothService: context.read<BluetoothService>(),
            ),
          ),
          BlocProvider(
            create: (context) => AiChatBloc(getIt()),
            child: MaterialApp.router(
              routerConfig: AppRouter.router,
              // ...
            ),
          )
        ],
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
          title: 'Health Ring AI',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }
}
