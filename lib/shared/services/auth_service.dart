// Serviço de autenticação MyFretes
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthService {
  /// Cadastra um novo usuário com nome, telefone, email, senha e role.
  /// Role deve ser 'cliente' ou 'motorista'.
  Future<AuthResponse> signUp({
    required String nome,
    required String telefone,
    required String email,
    required String senha,
    required String role,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: senha,
      data: {
        'nome': nome,
        'telefone': telefone,
        'role': role,
      },
    );

    // Cria o perfil na tabela profiles após o cadastro
    if (response.user != null) {
      await supabase.from('profiles').upsert({
        'id': response.user!.id,
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'role': role,
        'criado_em': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  /// Realiza login com email e senha.
  Future<AuthResponse> signIn({
    required String email,
    required String senha,
  }) async {
    return supabase.auth.signInWithPassword(
      email: email,
      password: senha,
    );
  }

  /// Retorna o perfil do usuário logado a partir da tabela `profiles`.
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data;
  }

  /// Retorna o usuário atual (se logado).
  User? get currentUser => supabase.auth.currentUser;

  /// Verifica se há usuário logado.
  bool get isLoggedIn => currentUser != null;

  /// Retorna a role do usuário logado ou null.
  Future<String?> getCurrentRole() async {
    final user = currentUser;
    if (user == null) return null;
    final profile = await getProfile(user.id);
    return profile?['role'] as String?;
  }

  /// Realiza logout.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
