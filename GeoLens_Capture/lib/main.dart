import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_cubit.dart';
import 'package:geolens_capture/features/dashboard/repositories/upload_repository.dart';
import 'package:geolens_capture/core/services/background_sync_service.dart';
import 'package:geolens_capture/core/services/connectivity_service.dart';
import 'package:geolens_capture/features/dashboard/views/dashboard_screen.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    'upload-sync-periodic',
    uploadSyncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          UploadQueueCubit(UploadRepository(), ConnectivityService()),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: DashboardScreen(),
      ),
    );
  }
}
