import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/frete_models.dart';

/// Serviço responsável por persistir fretes e seus dados relacionados
/// no Supabase, respeitando as políticas de RLS configuradas.
class FreteService {
  final _supabase = Supabase.instance.client;

  /// Cria um frete completo (frete + paradas + itens) de forma transacional
  /// sequencial: insere o frete primeiro para obter o ID, depois insere
  /// paradas e itens referenciando esse ID.
  ///
  /// Retorna `null` em caso de sucesso ou uma mensagem de erro localizada.
  Future<String?> criarFrete({
    required String titulo,
    required String descricao,
    DateTime? dataDesejada,
    required String periodo,
    required FreteEnderecoData origem,
    required List<FreteEnderecoData> paradas,
    required FreteEnderecoData destino,
    required List<FreteItemData> itens,
    required int quantidadeAjudantes,
    required bool precisaMontagem,
    required bool precisaEmbalagem,
    required String observacoesAjudantes,
  }) async {
    try {
      final clienteId = _supabase.auth.currentUser?.id;
      if (clienteId == null) return 'Usuário não autenticado.';

      // 1. Inserir frete principal
      final freteRow = await _supabase
          .from('fretes')
          .insert({
            'cliente_id': clienteId,
            'status': 'aberto',
            'titulo': titulo.isEmpty ? null : titulo,
            'descricao': descricao.isEmpty ? null : descricao,
            'data_desejada':
                dataDesejada?.toIso8601String().split('T').first,
            'periodo': periodo.isEmpty ? null : periodo,
            ...origem.toInsertMap(prefix: 'origem'),
            ...destino.toInsertMap(prefix: 'destino'),
            'qtd_ajudantes': quantidadeAjudantes,
            'precisa_montagem': precisaMontagem,
            'precisa_embalagem': precisaEmbalagem,
            'obs_ajudantes':
                observacoesAjudantes.isEmpty ? null : observacoesAjudantes,
          })
          .select('id')
          .single();

      final freteId = freteRow['id'] as String;

      // 2. Inserir paradas intermediárias (se houver)
      if (paradas.isNotEmpty) {
        await _supabase.from('frete_paradas').insert(
              paradas
                  .asMap()
                  .entries
                  .map((e) => {
                        'frete_id': freteId,
                        'ordem': e.key,
                        ...e.value.toParadaMap(),
                      })
                  .toList(),
            );
      }

      // 3. Inserir itens do frete (se houver)
      if (itens.isNotEmpty) {
        await _supabase.from('frete_itens').insert(
              itens
                  .map((item) => {
                        'frete_id': freteId,
                        ...item.toInsertMap(),
                      })
                  .toList(),
            );
      }

      return null; // sucesso
    } on PostgrestException catch (e) {
      assert(() {
        debugPrint('[FreteService] PostgrestException: ${e.message}');
        return true;
      }());
      return 'Erro ao salvar frete: ${e.message}';
    } catch (e) {
      assert(() {
        debugPrint('[FreteService] Erro inesperado: $e');
        return true;
      }());
      return 'Erro inesperado. Tente novamente.';
    }
  }
}
