import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class HomeMotoristPage extends StatelessWidget {
  const HomeMotoristPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFretes — Motorista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await AuthController().sair();
              if (context.mounted) context.go(RouteNames.welcome);
            },
          ),
        ],
      ),
      body: const _HomeMotoristBody(),
    );
  }
}

class _HomeMotoristBody extends StatelessWidget {
  const _HomeMotoristBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.drive_eta, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo, Motorista!',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Em breve: painel de fretes disponíveis.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
