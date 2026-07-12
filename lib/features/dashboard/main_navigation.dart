import 'package:flutter/material.dart';
import '../dashboard/view/dashboard_screen.dart';
import '../document/document_list/view/document_list_screen.dart';
import '../document/add_document/view/add_doc_screen.dart';
import '../profile/view/profile_screen.dart';
import '../pic/view/pic_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final GlobalKey<DocumentListScreenState> _documentListKey =
      GlobalKey<DocumentListScreenState>();

  // Urutan WAJIB SAMA dengan urutan nav item di bawah:
  // 0 = Home, 1 = PIC, 2 = Pekerjaan, 3 = Akun
  late final List<Widget> _screens = [
    const HomeScreen(),
    const PicScreen(),
    DocumentListScreen(key: _documentListKey),
    const ProfileScreen(),
  ];

  bool get _isOnPekerjaanTab => _selectedIndex == 2;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: _isOnPekerjaanTab
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
                );
                if (result == true) {
                  _documentListKey.currentState?.refreshDocuments();
                }
              },
              backgroundColor: primaryColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 36, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: _isOnPekerjaanTab ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0,
        color: primaryColor,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Icons.home, 'Home', 0),
              _buildNavItem(context, Icons.people_outline, 'PIC', 1),
              _buildNavItem(context, Icons.assignment, 'Pekerjaan', 2),
              _buildNavItem(context, Icons.person, 'Akun', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}