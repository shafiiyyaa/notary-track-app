import 'package:flutter/material.dart';
import 'package:notarytrackapp/features/onboarding/view/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bwmixsdyqmrkdbxalzyr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3bWl4c2R5cW1ya2RieGFsenlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzODYyMzIsImV4cCI6MjA5NTk2MjIzMn0.ZVm6ZEDlN2tooY1x2NGhZGnA3_uqGVwcu7arcz0Fm0Y',
  );

  runApp(const NotaryTrackApp());
}

class NotaryTrackApp extends StatelessWidget {
  const NotaryTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotaryTrackApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 91, 141, 184),
        primaryColor: const Color.fromRGBO(91, 141, 184, 1),
        useMaterial3: true,
      ),
      home: const CustomSplashScreen(),
    );
  }
}
