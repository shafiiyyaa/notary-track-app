import 'package:flutter/material.dart';
import '../dashboard/view/dashboard_screen.dart';
import '../document/document_list/view/document_list_screen.dart';
import '../document/add_document/view/add_doc_screen.dart';
import '../profile/view/profile_screen.dart';
import '../history/view/history_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const DocumentListScreen(),
     const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
        ),
        backgroundColor: const Color(0xFFABC8E2),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF5B8DB8),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.assignment, 'Dokumen', 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.history, 'Riwayat', 2),
              _buildNavItem(Icons.person, 'Akun', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.white70,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
