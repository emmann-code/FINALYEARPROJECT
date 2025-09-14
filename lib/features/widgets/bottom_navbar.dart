// ignore_for_file: prefer_const_constructors_in_immutables, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';

/// A modern, customizable bottom navigation bar for the app.
class CustomBottomNavBar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // --- Navigation Items Data ---
  static const List<_NavBarItemData> _items = [
    _NavBarItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavBarItemData(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavBarItemData(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      label: 'Spybox',
    ),
    _NavBarItemData(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'History',
    ),
    _NavBarItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return _ModernNavItem(
            icon: item.icon,
            activeIcon: item.activeIcon,
            label: item.label,
            index: index,
            isSelected: selectedIndex == index,
            isDarkMode: isDarkMode,
            onTap: onItemTapped,
          );
        }),
      ),
    );
  }
}

/// Data class for navigation bar items.
class _NavBarItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A single navigation item widget for the bottom nav bar.
class _ModernNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool isSelected;
  final bool isDarkMode;
  final ValueChanged<int> onTap;

  const _ModernNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Colors.blue.shade600;
    final Color unselectedColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500;
    final Color selectedBackgroundColor = isDarkMode
        ? Colors.blue.shade900.withOpacity(0.3)
        : Colors.blue.shade50;
    final Color selectedBorderColor =
        isDarkMode ? Colors.blue.shade700 : Colors.blue.shade200;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: selectedBorderColor, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: isSelected ? 24 : 22,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selectedColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
