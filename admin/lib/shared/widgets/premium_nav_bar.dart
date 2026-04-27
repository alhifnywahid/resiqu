import 'package:flutter/material.dart';

/// Nav bar items row — used inside Scaffold's bottomNavigationBar (BottomAppBar).
/// The FAB scan button lives in Scaffold.floatingActionButton (centerDocked).
class PremiumNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const PremiumNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: const Color(0xFF3B82F6), // Premium Blue
      padding: EdgeInsets.zero,
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavItem(
            icon: Icons.all_inbox_rounded,
            label: 'Paket',
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          // Center gap for FAB
          const SizedBox(width: 56),
          _NavItem(
            icon: Icons.widgets_rounded,
            label: 'Box',
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
          _NavItem(
            icon: Icons.people_rounded,
            label: 'User',
            isSelected: selectedIndex == 4,
            onTap: () => onItemTapped(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const _active = Colors.white;
  static final _inactive = Colors.white.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circle indicator background
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? _active.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSelected ? _active : _inactive,
            ),
          ),
          const SizedBox(height: 1),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? _active : _inactive,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
