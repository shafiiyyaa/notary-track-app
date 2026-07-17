import 'package:flutter/material.dart';
import 'client_home_screen.dart';
import 'client_notification_screen.dart';
import 'client_profile_screen.dart';

class ClientNavigation extends StatefulWidget {
  const ClientNavigation({super.key});

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ClientHomeScreen(),
    const ClientNotificationScreen(),
    const ClientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Dokumen'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}