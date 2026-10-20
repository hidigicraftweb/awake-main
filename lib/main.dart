import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/services/cafe_service.dart';
import 'core/services/cart_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/city/city_bloc.dart';
import 'presentation/blocs/city/city_event.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/product/product_event.dart';
import 'presentation/pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  // Initialize CafeService
  await CafeService().init();

  // Initialize CartService (load from local storage)
  await CartService().init();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AwakeApp());
}

class AwakeApp extends StatelessWidget {
  const AwakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => sl<CityBloc>()..add(const CitiesFetchRequested()),
        ),
        BlocProvider(
          create: (_) => sl<ProductBloc>()..add(const FeaturedProductsFetchRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Awake Coffee',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
      ),
    );
  }
}
