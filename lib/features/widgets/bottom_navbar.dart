import 'package:flutter/material.dart';

class custombottomnavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const custombottomnavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12                                                                                                                       ),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      decoration: BoxDecoration(
         gradient: const LinearGradient(
          colors: [Color(0xFF72B4F6), Color(0xFF6A5ACD)], // Light blue to purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // color: Color(0xFF428AC4), // Background color of the nav bar
        borderRadius: BorderRadius.circular(30.0), // Rounded edges
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Home',
            index: 0,
            isSelected: selectedIndex == 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            index: 1,
            isSelected: selectedIndex == 1,
          ),
          _buildNavItem(
            context,
            icon: Icons.history_edu,
            label: 'Spybox',
            index: 2,
            isSelected: selectedIndex == 2,
          ),
          _buildNavItem(
            context,
            icon: Icons.history,
            label: 'History',
            index: 3,
            isSelected: selectedIndex == 3,
          ),
          _buildNavItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            index: 4,
            isSelected: selectedIndex == 4,
          ),
        ],
      ),
    );
  }

  // Function to build each navigation item
  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String label, required int index, required bool isSelected}) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration:
        BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 46, 44, 53) : Colors.transparent, // Highlight when selected
          borderRadius: BorderRadius.circular(20.0), // Rounded edges for each icon
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color.fromARGB(255, 233, 237, 238) : Colors.black87,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 233, 237, 238),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
