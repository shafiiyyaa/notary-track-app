import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:notarytrackapp/features/onboarding/view/splash_screen.dart';
import 'package:notarytrackapp/services/notification_service.dart';

import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(

    url: 'https://bwmixsdyqmrkdbxalzyr.supabase.co',

    anonKey:

        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3bWl4c2R5cW1ya2RieGFsenlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzODYyMzIsImV4cCI6MjA5NTk2MjIzMn0.ZVm6ZEDlN2tooY1x2NGhZGnA3_uqGVwcu7arcz0Fm0Y',

  );

  // Inisialisasi Notification
  await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NotaryTrackApp(),
    ),
  );
}

class NotaryTrackApp extends StatelessWidget {
  const NotaryTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'NotaryTrackApp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const CustomSplashScreen(),
        );
      },
    );
  }
}