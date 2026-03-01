import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prm393_g3_frontend/features/branches/presentation/pages/branch_list_page.dart';
import 'package:prm393_g3_frontend/features/branches/presentation/pages/create_branch_page.dart';
import 'core/di/service_locator.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(const ProductRequested()),
      child: MaterialApp(
        title: 'Retail Chain Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          '/branch-list': (_) => const BranchListPage(),
          '/create-branch': (_) => const CreateBranchPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
