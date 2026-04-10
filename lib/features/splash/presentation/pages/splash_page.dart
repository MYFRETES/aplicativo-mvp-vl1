import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(RouteNames.welcome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(child: _LogoMyFretes()),
      ),
    );
  }
}

class _LogoMyFretes extends StatelessWidget {
  const _LogoMyFretes();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(
            text: 'MY',
            style: TextStyle(color: AppColors.accent),
          ),
          TextSpan(
            text: 'fretes',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
