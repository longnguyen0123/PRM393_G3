import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              Icons.home,
              'Home',
              0,
              () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
            ),
            _buildNavItem(
              context,
              Icons.list,
              'Products',
              1,
              () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProductListPage()),
                  (route) => route.settings.name == '/',
                );
              },
            ),
            _buildNavItem(
              context,
              Icons.settings,
              'Settings',
              2,
              () {
                // Navigate to Settings - can be implemented later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings page coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
