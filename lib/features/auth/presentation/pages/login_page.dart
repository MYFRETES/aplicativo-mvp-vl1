// Tela de Login - MyFretes
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _controller = AuthController();
  bool _obscureSenha = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final role = await _controller.signIn(
      email: _emailCtrl.text.trim(),
      senha: _senhaCtrl.text,
    );

    if (!mounted) return;

    if (role == 'cliente') {
      context.go(RouteNames.customerHome);
    } else if (role == 'motorista') {
      context.go(RouteNames.driverHome);
    } else if (_controller.errorMessage != null) {
      _showError(_controller.errorMessage!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.loginTitulo),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone
                const Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // E-mail
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.campoObrigatorio;
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return AppStrings.emailInvalido;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _senhaCtrl,
                  obscureText: _obscureSenha,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: AppStrings.senha,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureSenha
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureSenha = !_obscureSenha),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.campoObrigatorio;
                    }
                    if (v.length < 6) return AppStrings.senhaMinima;
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Esqueci a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: implementar recuperação de senha
                    },
                    child: const Text(AppStrings.esqueciSenha),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão entrar
                ListenableBuilder(
                  listenable: _controller,
                  builder: (_, __) => ElevatedButton(
                    onPressed: _controller.isLoading ? null : _login,
                    child: _controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.entrar),
                  ),
                ),
                const SizedBox(height: 24),

                // Link para cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.naoTemConta,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text(AppStrings.cadastreSe),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
