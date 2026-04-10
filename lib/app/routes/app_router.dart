// Roteador principal do app MyFretes com go_router
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/customer/presentation/pages/customer_home_page.dart';
import '../../features/driver/presentation/pages/driver_home_page.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.welcome,
      name: 'boas-vindas',
      builder: (_, __) => const WelcomePage(),
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'cadastro',
      builder: (context, state) {
        final role = state.extra as String?;
        return RegisterPage(initialRole: role);
      },
    ),
    GoRoute(
      path: RouteNames.customerHome,
      name: 'cliente-home',
      builder: (_, __) => const CustomerHomePage(),
    ),
    GoRoute(
      path: RouteNames.driverHome,
      name: 'motorista-home',
      builder: (_, __) => const DriverHomePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Página não encontrada: ${state.uri}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
  ),
);
