import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de autenticação via Supabase.
///
/// **Estratégia de criação do profile:**
/// A tabela `profiles` é populada automaticamente via trigger SQL no Supabase,
/// disparado após a inserção em `auth.users`. Isso torna o fluxo mais robusto,
/// pois independe de chamadas do cliente logo após o `signUp`.
///
/// Consulte `supabase/migrations/20240101000000_create_profiles_trigger.sql`
/// para o script do trigger recomendado.
///
/// Como fallback, o método [cadastrar] tenta um `upsert` na tabela `profiles`
/// caso o trigger ainda não esteja configurado no projeto.
class AuthService {
  final _supabase = Supabase.instance.client;

  /// Realiza cadastro do usuário.
  ///
  /// Retorna `null` em caso de sucesso ou uma mensagem de erro localizada.
  Future<String?> cadastrar({
    required String email,
    required String senha,
    required String nomeCompleto,
    required String telefone,
    required String perfil,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: senha,
        data: {
          'nome_completo': nomeCompleto,
          'telefone': telefone,
          'perfil': perfil,
        },
      );

      final userId = response.user?.id;
      if (userId == null) {
        return 'Não foi possível criar a conta. Tente novamente.';
      }

      // Fallback: tenta criar o profile no cliente caso o trigger SQL
      // não esteja configurado no Supabase. O trigger é a abordagem preferida.
      await _upsertProfileFallback(
        userId: userId,
        nomeCompleto: nomeCompleto,
        telefone: telefone,
        perfil: perfil,
        email: email,
      );

      return null; // sucesso
    } on AuthException catch (e) {
      return _traduzirErroAuth(e.message);
    } catch (_) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  /// Realiza login do usuário.
  ///
  /// Retorna `null` em caso de sucesso ou uma mensagem de erro localizada.
  Future<String?> entrar({
    required String email,
    required String senha,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      return null; // sucesso
    } on AuthException catch (e) {
      return _traduzirErroAuth(e.message);
    } catch (_) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  /// Retorna o perfil do usuário logado ('cliente' ou 'motorista').
  Future<String> buscarPerfil() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 'cliente';

    try {
      final data = await _supabase
          .from('profiles')
          .select('perfil')
          .eq('id', userId)
          .maybeSingle();

      return (data?['perfil'] as String?) ?? 'cliente';
    } catch (_) {
      return 'cliente';
    }
  }

  Future<void> sair() async {
    await _supabase.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Métodos privados
  // ---------------------------------------------------------------------------

  /// Tenta criar/atualizar o registro em `profiles` diretamente pelo cliente.
  /// Serve como fallback quando o trigger SQL não está configurado.
  /// Falhas silenciosas são aceitáveis aqui — o trigger é o mecanismo principal.
  Future<void> _upsertProfileFallback({
    required String userId,
    required String nomeCompleto,
    required String telefone,
    required String perfil,
    required String email,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'nome_completo': nomeCompleto,
        'telefone': telefone,
        'perfil': perfil,
        'email': email,
      });
    } catch (_) {
      // Falha silenciosa: o trigger SQL é o mecanismo preferido.
    }
  }

  String _traduzirErroAuth(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('email already registered') ||
        msg.contains('user already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('password should be')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (msg.contains('unable to validate email')) {
      return 'E-mail inválido.';
    }
    return message;
  }
}
