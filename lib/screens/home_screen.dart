import 'package:flutter/material.dart';
import 'package:laura/screens/movement_screen.dart';
import 'package:laura/screens/chart_screen.dart';
import 'package:laura/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MovementScreen(),
    ChartScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Movimentações'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Gráficos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configurações'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
