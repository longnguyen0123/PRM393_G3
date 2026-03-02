import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prm393_g3_frontend/core/di/service_locator.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:prm393_g3_frontend/features/branches/presentation/pages/branch_list_page.dart';
import 'package:prm393_g3_frontend/features/branches/presentation/pages/create_branch_page.dart';
import 'package:prm393_g3_frontend/features/home/presentation/pages/home_page.dart';
import 'package:prm393_g3_frontend/features/products/presentation/bloc/product_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<ProductBloc>(
          create: (_) => getIt<ProductBloc>()..add(const ProductRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Retail Chain Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/home': (_) => const HomePage(),
          '/branch-list': (_) => const BranchListPage(),
          '/create-branch': (_) => const CreateBranchPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
