import 'package:flutter/material.dart';
import 'awards_section/awards_page.dart';
import 'quests_section/quests_page.dart';

class BottomNavBar extends StatefulWidget {
  final String currentPage;
  const BottomNavBar({super.key, required this.currentPage});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set the initial selected index based on the current page
    _selectedIndex = widget.currentPage == 'awards' ? 0 : 1;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Pop all routes until we're back to the root
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Push the new route
    switch (index) {
      case 0: // Awards
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AwardsPage()),
        );
        break;
      case 1: // Quests
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestsPage()),
        );
        break;
      // Add other cases for other navigation items as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF1A2530),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.emoji_events, _selectedIndex == 0),
          _buildNavItem(Icons.car_repair, _selectedIndex == 1),
          _buildNavItem(Icons.home, _selectedIndex == 2),
          _buildNavItem(Icons.directions_car, _selectedIndex == 3),
          _buildNavItem(Icons.map, _selectedIndex == 4),
          _buildNavItem(Icons.store, _selectedIndex == 5),
          _buildNavItem(Icons.person, _selectedIndex == 6),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(children.indexOf(icon)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAB6C40) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  final List<IconData> children = [
    Icons.emoji_events,
    Icons.car_repair,
    Icons.home,
    Icons.directions_car,
    Icons.map,
    Icons.store,
    Icons.person,
  ];
}
