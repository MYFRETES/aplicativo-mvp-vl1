import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/customer/presentation/controllers/novo_frete_controller.dart';

/// Serviço responsável pela persistência de fretes no Supabase.
///
/// Mantém-se desacoplado de framework de UI — apenas Supabase e models.
class FreteService {
  final _supabase = Supabase.instance.client;

  /// Persiste um novo frete (com paradas e itens) no Supabase.
  ///
  /// Retorna `null` em caso de sucesso ou uma mensagem de erro localizada.
  Future<String?> salvarFrete(NovoFreteController c) async {
    try {
      final clienteId = _supabase.auth.currentUser?.id;
      if (clienteId == null) {
        return 'Usuário não autenticado. Faça login e tente novamente.';
      }

      // 1. Inserir o frete e obter o ID gerado
      final freteRow = await _supabase
          .from('fretes')
          .insert(c.toFreteMap(clienteId))
          .select('id')
          .single();

      final freteId = freteRow['id'] as String;

      // 2. Inserir paradas intermediárias (se houver)
      if (c.paradas.isNotEmpty) {
        final paradasData = c.paradas
            .asMap()
            .entries
            .map((e) => e.value.toMap(freteId, e.key))
            .toList();
        await _supabase.from('frete_paradas').insert(paradasData);
      }

      // 3. Inserir itens (filtra itens sem nome para evitar registros em branco)
      final itensValidos = c.itens
          .asMap()
          .entries
          .where((e) => e.value.nomeCtrl.text.trim().isNotEmpty)
          .map((e) => e.value.toMap(freteId, e.key))
          .toList();

      if (itensValidos.isNotEmpty) {
        await _supabase.from('frete_itens').insert(itensValidos);
      }

      return null; // sucesso
    } catch (e) {
      assert(() {
        debugPrint('[FreteService] Erro ao salvar frete: $e');
        return true;
      }());
      return 'Erro ao enviar solicitação. Verifique sua conexão e tente novamente.';
    }
  }
}
