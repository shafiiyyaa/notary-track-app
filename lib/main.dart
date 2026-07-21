import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:notarytrackapp/features/onboarding/view/splash_screen.dart';
import 'package:notarytrackapp/features/notification/services/notification_service.dart';
import 'theme/app_theme.dart';

// GlobalKey ini dipakai NotificationService untuk membuka halaman
// walaupun tidak ada BuildContext (misal saat notifikasi di-tap).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://bwmixsdyqmrkdbxalzyr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3bWl4c2R5cW1ya2RieGFsenlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzODYyMzIsImV4cCI6MjA5NTk2MjIzMn0.ZVm6ZEDlN2tooY1x2NGhZGnA3_uqGVwcu7arcz0Fm0Y',
  );

  await NotificationService().init();

  runApp(const NotaryTrackApp());
}

class NotaryTrackApp extends StatelessWidget {
  const NotaryTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // WAJIB, dipakai NotificationService
      title: 'NotaryTrackApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CustomSplashScreen(),
    );
  }
}