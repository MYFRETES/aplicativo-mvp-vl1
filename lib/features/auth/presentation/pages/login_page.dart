import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  /// Mensagem de sucesso exibida após um cadastro bem-sucedido.
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _controller = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await _controller.entrar(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) return;

    if (ok) {
      final perfil = await _controller.buscarPerfil();
      if (!mounted) return;
      context.go(
        perfil == 'motorista'
            ? RouteNames.homeMotorista
            : RouteNames.homeCliente,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.erro ?? 'Erro ao entrar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.successMessage!,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: AppStrings.email),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o e-mail.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: AppStrings.senha),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe a senha.' : null,
                ),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (_, __) {
                    return ElevatedButton(
                      onPressed: _controller.loading ? null : _entrar,
                      child: _controller.loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Acessar conta'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.push(RouteNames.register),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
