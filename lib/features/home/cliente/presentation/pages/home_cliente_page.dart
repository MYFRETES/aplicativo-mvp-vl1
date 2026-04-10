import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class HomeClientePage extends StatelessWidget {
  const HomeClientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFretes — Cliente'),
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
      body: const _HomeClienteBody(),
    );
  }
}

class _HomeClienteBody extends StatelessWidget {
  const _HomeClienteBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping,
                size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo, Cliente!',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Solicite um frete de forma rápida e simples.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.novoFrete),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Novo Frete'),
            ),
          ],
        ),
      ),
    );
  }
}

