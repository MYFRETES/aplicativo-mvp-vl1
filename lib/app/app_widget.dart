// Widget raiz do app MyFretes
import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_strings.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
