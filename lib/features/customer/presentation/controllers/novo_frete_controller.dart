import 'package:flutter/material.dart';

import '../../../../../shared/models/frete_models.dart';
import '../../../../../shared/services/frete_service.dart';

/// Gerencia o estado completo do formulário de novo frete.
///
/// Cada propriedade pública corresponde diretamente a uma etapa do formulário.
/// Widgets atualizam os campos diretamente via setters e mutação dos objetos
/// de modelo. [notifyListeners] é chamado apenas para mudanças estruturais
/// (avançar/voltar de etapa, adicionar/remover paradas e itens).
class NovoFreteController extends ChangeNotifier {
  final FreteService _service;

  NovoFreteController({FreteService? service})
      : _service = service ?? FreteService();

  // ── Navegação ─────────────────────────────────────────────────────────────

  int _etapaAtual = 0;
  bool _loading = false;
  String? _erro;

  int get etapaAtual => _etapaAtual;
  bool get loading => _loading;
  String? get erro => _erro;

  static const int totalEtapas = 7;

  void avancar() {
    if (_etapaAtual < totalEtapas - 1) {
      _etapaAtual++;
      notifyListeners();
    }
  }

  void voltar() {
    if (_etapaAtual > 0) {
      _etapaAtual--;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  // ── Etapa 0 — Dados iniciais ──────────────────────────────────────────────

  String titulo = '';
  String descricao = '';
  DateTime? dataDesejada;
  String periodo = '';

  // ── Etapa 1 — Origem ─────────────────────────────────────────────────────

  final origem = FreteEnderecoData();

  // ── Etapa 2 — Paradas intermediárias ─────────────────────────────────────

  final List<FreteEnderecoData> paradas = [];

  void adicionarParada() {
    paradas.add(FreteEnderecoData());
    notifyListeners();
  }

  void removerParada(int index) {
    if (index >= 0 && index < paradas.length) {
      paradas.removeAt(index);
      notifyListeners();
    }
  }

  // ── Etapa 3 — Destino ─────────────────────────────────────────────────────

  final destino = FreteEnderecoData();

  // ── Etapa 4 — Itens ──────────────────────────────────────────────────────

  final List<FreteItemData> itens = [];

  void adicionarItem() {
    itens.add(FreteItemData());
    notifyListeners();
  }

  void removerItem(int index) {
    if (index >= 0 && index < itens.length) {
      itens.removeAt(index);
      notifyListeners();
    }
  }

  // ── Etapa 5 — Ajudantes ──────────────────────────────────────────────────

  int quantidadeAjudantes = 0;
  bool precisaMontagem = false;
  bool precisaEmbalagem = false;
  String observacoesAjudantes = '';

  void setQuantidadeAjudantes(int v) {
    quantidadeAjudantes = v.clamp(0, 10);
    notifyListeners();
  }

  void setMontagem(bool v) {
    precisaMontagem = v;
    notifyListeners();
  }

  void setEmbalagem(bool v) {
    precisaEmbalagem = v;
    notifyListeners();
  }

  // ── Submissão ─────────────────────────────────────────────────────────────

  /// Persiste o frete no Supabase.
  /// Retorna `true` em caso de sucesso.
  Future<bool> submeter() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    final erro = await _service.criarFrete(
      titulo: titulo,
      descricao: descricao,
      dataDesejada: dataDesejada,
      periodo: periodo,
      origem: origem,
      paradas: paradas,
      destino: destino,
      itens: itens,
      quantidadeAjudantes: quantidadeAjudantes,
      precisaMontagem: precisaMontagem,
      precisaEmbalagem: precisaEmbalagem,
      observacoesAjudantes: observacoesAjudantes,
    );

    _erro = erro;
    _loading = false;
    notifyListeners();
    return erro == null;
  }
}
