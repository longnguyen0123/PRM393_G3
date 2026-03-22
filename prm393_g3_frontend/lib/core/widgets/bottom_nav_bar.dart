import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin =
            authState is AuthAuthenticated && authState.user.role == 'ADMIN';
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
                  isAdmin: isAdmin,
                ),
                if (isAdmin)
                  _buildNavItem(
                    context,
                    Icons.list,
                    'Products',
                    1,
                    () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const ProductListPage(),
                        ),
                        (route) => route.settings.name == '/',
                      );
                    },
                    isAdmin: isAdmin,
                  ),
                _buildNavItem(
                  context,
                  Icons.settings,
                  'Settings',
                  2,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings page coming soon'),
                      ),
                    );
                  },
                  isAdmin: isAdmin,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    VoidCallback onTap, {
    required bool isAdmin,
  }) {
    final isSelected = isAdmin
        ? currentIndex == index
        : (index == 0 ? currentIndex == 0 : currentIndex == 2);
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
