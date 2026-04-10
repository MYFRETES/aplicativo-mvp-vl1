// Controller de autenticação do MyFretes
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../core/constants/app_strings.dart';

enum AuthStatus { idle, loading, success, error }

class AuthController extends ChangeNotifier {
  final AuthService _authService;

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String? _role;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get role => _role;
  bool get isLoading => _status == AuthStatus.loading;

  /// Realiza cadastro e retorna a role do usuário criado.
  Future<String?> signUp({
    required String nome,
    required String telefone,
    required String email,
    required String senha,
    required String confirmarSenha,
    required String role,
  }) async {
    if (senha != confirmarSenha) {
      _setError(AppStrings.senhasDivergentes);
      return null;
    }

    _setLoading();
    try {
      final response = await _authService.signUp(
        nome: nome,
        telefone: telefone,
        email: email,
        senha: senha,
        role: role,
      );

      if (response.user != null) {
        _role = role;
        _setSuccess();
        return role;
      } else {
        _setError(AppStrings.erroGenerico);
        return null;
      }
    } catch (e) {
      _setError(_friendlyError(e));
      return null;
    }
  }

  /// Realiza login e retorna a role do usuário.
  Future<String?> signIn({
    required String email,
    required String senha,
  }) async {
    _setLoading();
    try {
      final response = await _authService.signIn(
        email: email,
        senha: senha,
      );

      if (response.user != null) {
        final profile = await _authService.getProfile(response.user!.id);
        _role = profile?['role'] as String?;
        _setSuccess();
        return _role;
      } else {
        _setError(AppStrings.erroGenerico);
        return null;
      }
    } catch (e) {
      _setError(_friendlyError(e));
      return null;
    }
  }

  /// Realiza logout.
  Future<void> signOut() async {
    await _authService.signOut();
    _role = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  /// Verifica a sessão atual e retorna a role, se logado.
  Future<String?> checkSession() async {
    try {
      final roleStr = await _authService.getCurrentRole();
      _role = roleStr;
      return roleStr;
    } catch (_) {
      return null;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_status == AuthStatus.error) {
      _status = AuthStatus.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  String _friendlyError(Object e) {
    // Usa AuthException do supabase_flutter para identificar erros de forma robusta
    if (e is AuthException) {
      final statusCode = e.statusCode;
      final message = e.message.toLowerCase();

      // Credenciais inválidas (HTTP 400 ou mensagem de credenciais)
      if (statusCode == '400' ||
          message.contains('invalid_credentials') ||
          message.contains('invalid login credentials')) {
        return 'E-mail ou senha incorretos.';
      }
      // Usuário já existe (HTTP 422)
      if (statusCode == '422' ||
          message.contains('user already registered') ||
          message.contains('email already registered') ||
          message.contains('already been registered')) {
        return 'Este e-mail já está cadastrado.';
      }
      // Token expirado (HTTP 401)
      if (statusCode == '401') {
        return 'Sessão expirada. Faça login novamente.';
      }
      // Devolve a mensagem original do Supabase traduzida, se disponível
      return e.message.isNotEmpty ? e.message : AppStrings.erroGenerico;
    }

    // Erros de rede/socket não são AuthException
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet.';
    }

    return AppStrings.erroGenerico;
  }
}
