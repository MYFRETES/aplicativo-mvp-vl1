// Home do Cliente - MyFretes
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final _authController = AuthController();
  int _tabIndex = 0;

  Future<void> _sair() async {
    await _authController.signOut();
    if (!mounted) return;
    context.go(RouteNames.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: AppStrings.sair,
            onPressed: _sair,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _MeusPedidosTab(),
          _PerfilTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Meus Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: navegar para novo frete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Formulário de frete será implementado no próximo passo.'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.novoFrete),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

class _MeusPedidosTab extends StatelessWidget {
  const _MeusPedidosTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.semPedidos,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilTab extends StatelessWidget {
  const _PerfilTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Meu Perfil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 32),
          _InfoTile(
            icon: Icons.badge_outlined,
            label: 'Tipo de conta',
            value: AppStrings.cliente,
          ),
          const Divider(),
          // TODO: exibir dados reais do perfil
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
