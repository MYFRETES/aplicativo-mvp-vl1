import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _controller = AuthController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String _perfilSelecionado = 'cliente';

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await _controller.cadastrar(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      nomeCompleto: _nomeController.text.trim(),
      telefone: _phoneMask.getMaskedText(),
      perfil: _perfilSelecionado,
    );

    if (!mounted) return;

    if (ok) {
      // Após cadastro bem-sucedido, redireciona para login com mensagem de sucesso.
      // NÃO vai direto para home — evita problemas de confirmação de e-mail
      // ou timing de sessão no Supabase.
      // Usa `extra` para passar dado transiente sem poluir a URL.
      context.go(RouteNames.login, extra: AppStrings.cadastroSucesso);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.erro ?? 'Erro ao cadastrar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                      labelText: AppStrings.nomeCompleto),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Informe o nome completo.'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMask],
                  decoration: const InputDecoration(
                      labelText: AppStrings.telefone),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Informe o telefone.'
                          : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _perfilSelecionado,
                  decoration:
                      const InputDecoration(labelText: 'Perfil'),
                  items: const [
                    DropdownMenuItem(
                        value: 'cliente', child: Text('Cliente')),
                    DropdownMenuItem(
                        value: 'motorista', child: Text('Motorista')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _perfilSelecionado = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: AppStrings.email),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Informe o e-mail.'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: AppStrings.senha),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha.';
                    if (v.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: AppStrings.confirmarSenha),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirme a senha.';
                    }
                    if (v != _senhaController.text) {
                      return AppStrings.erroSenhasNaoCoincidem;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (_, __) {
                    return ElevatedButton(
                      onPressed: _controller.loading ? null : _cadastrar,
                      child: _controller.loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Criar minha conta'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Já tenho conta. Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
