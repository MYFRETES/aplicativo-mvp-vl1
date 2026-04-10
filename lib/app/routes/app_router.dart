import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/cliente/presentation/pages/home_cliente_page.dart';
import '../../features/home/motorista/presentation/pages/home_motorista_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'route_names.dart';

class AppRouter {
  static final _supabase = Supabase.instance.client;

  static final router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final session = _supabase.auth.currentSession;
      final isLoggedIn = session != null;
      final isOnAuthPage = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.welcome ||
          state.matchedLocation == RouteNames.splash;

      if (isLoggedIn && isOnAuthPage) {
        // Após login, redireciona conforme perfil (padrão: cliente)
        return RouteNames.homeCliente;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.welcome,
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) {
          final successMessage =
              state.uri.queryParameters['mensagem'];
          return LoginPage(successMessage: successMessage);
        },
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.homeCliente,
        builder: (_, __) => const HomeClientePage(),
      ),
      GoRoute(
        path: RouteNames.homeMotorista,
        builder: (_, __) => const HomeMotoristPage(),
      ),
    ],
  );
}
