import 'package:flutter/material.dart';
import 'feed_view.dart';
import 'guide_view.dart';
import 'map_view.dart';
import 'activities.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedView(),
    const GuideView(),
    const MapView(),
    const ActivitiesView(),
    const ProfileView(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1A1A1A),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_filled, 0, 'Accueil'),
              _navItem(Icons.explore, 1, 'Guide'),
              const SizedBox(width: 40),
              _navItem(Icons.local_activity, 3, 'Activités'),
              _navItem(Icons.person, 4, 'Profil'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        shape: const CircleBorder(),
        onPressed: () => _onTap(2),
        child: const Icon(Icons.location_on, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => _onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.orangeAccent : Colors.grey),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.orangeAccent : Colors.grey)),
        ],
      ),
    );
  }
}
