import 'package:flutter/material.dart';

import '../data/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service;

  AuthController({AuthService? service})
      : _service = service ?? AuthService();

  bool _loading = false;
  String? _erro;

  bool get loading => _loading;
  String? get erro => _erro;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  /// Realiza o cadastro e retorna `true` em caso de sucesso.
  /// Em caso de erro, popula [erro] e retorna `false`.
  Future<bool> cadastrar({
    required String email,
    required String senha,
    required String nomeCompleto,
    required String telefone,
    required String perfil,
  }) async {
    _setLoading(true);
    _erro = null;

    final erro = await _service.cadastrar(
      email: email,
      senha: senha,
      nomeCompleto: nomeCompleto,
      telefone: telefone,
      perfil: perfil,
    );

    _erro = erro;
    _setLoading(false);
    return erro == null;
  }

  /// Realiza o login e retorna `true` em caso de sucesso.
  Future<bool> entrar({
    required String email,
    required String senha,
  }) async {
    _setLoading(true);
    _erro = null;

    final erro = await _service.entrar(email: email, senha: senha);

    _erro = erro;
    _setLoading(false);
    return erro == null;
  }

  Future<String> buscarPerfil() => _service.buscarPerfil();

  Future<void> sair() => _service.sair();
}
