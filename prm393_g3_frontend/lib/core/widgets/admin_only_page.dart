import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// Chỉ [ADMIN] mới thấy [child]; các role khác thấy thông báo và nút quay lại.
class AdminOnlyPage extends StatelessWidget {
  const AdminOnlyPage({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated || state.user.role != 'ADMIN') {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Chỉ quản trị viên được sử dụng chức năng này.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        } else {
                          nav.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
