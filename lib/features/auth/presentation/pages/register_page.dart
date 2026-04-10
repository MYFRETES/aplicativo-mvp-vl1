// Tela de Cadastro - MyFretes
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  /// Role pré-selecionada vinda da tela de boas-vindas ('cliente' ou 'motorista').
  final String? initialRole;

  const RegisterPage({super.key, this.initialRole});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  final _controller = AuthController();

  final _telMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _obscureSenha = true;
  bool _obscureConfirmar = true;
  late String _roleSelecionada;

  @override
  void initState() {
    super.initState();
    _roleSelecionada = widget.initialRole ?? 'cliente';
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final role = await _controller.signUp(
      nome: _nomeCtrl.text.trim(),
      telefone: _telCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      senha: _senhaCtrl.text,
      confirmarSenha: _confirmarCtrl.text,
      role: _roleSelecionada,
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
        title: const Text(AppStrings.cadastroTitulo),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seleção de perfil
                _PerfilSelector(
                  selecionado: _roleSelecionada,
                  onChanged: (v) => setState(() => _roleSelecionada = v),
                ),
                const SizedBox(height: 24),

                // Nome
                TextFormField(
                  controller: _nomeCtrl,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.nome,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? AppStrings.campoObrigatorio
                          : null,
                ),
                const SizedBox(height: 16),

                // Telefone
                TextFormField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_telMask],
                  decoration: const InputDecoration(
                    labelText: AppStrings.telefone,
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '(11) 91234-5678',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.campoObrigatorio;
                    }
                    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 10) return AppStrings.telefoneInvalido;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: 16),

                // Confirmar senha
                TextFormField(
                  controller: _confirmarCtrl,
                  obscureText: _obscureConfirmar,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _cadastrar(),
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmarSenha,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmar
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirmar = !_obscureConfirmar),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.campoObrigatorio;
                    }
                    if (v != _senhaCtrl.text) {
                      return AppStrings.senhasDivergentes;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão cadastrar
                ListenableBuilder(
                  listenable: _controller,
                  builder: (_, __) => ElevatedButton(
                    onPressed: _controller.isLoading ? null : _cadastrar,
                    child: _controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.cadastrar),
                  ),
                ),
                const SizedBox(height: 16),

                // Link para login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.jaTemContaLogin,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.login),
                      child: const Text(AppStrings.entrar),
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

class _PerfilSelector extends StatelessWidget {
  final String selecionado;
  final ValueChanged<String> onChanged;

  const _PerfilSelector({
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.perfil,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PerfilChip(
                label: AppStrings.cliente,
                icon: Icons.person_outline,
                selected: selecionado == 'cliente',
                onTap: () => onChanged('cliente'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PerfilChip(
                label: AppStrings.motorista,
                icon: Icons.drive_eta_outlined,
                selected: selecionado == 'motorista',
                onTap: () => onChanged('motorista'),
                selectedColor: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PerfilChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _PerfilChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? selectedColor : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
