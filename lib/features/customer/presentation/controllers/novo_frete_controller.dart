import 'package:flutter/material.dart';

/// Controla os campos de texto de uma parada intermediária.
class ParadaControllers {
  final cepCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final complementoCtrl = TextEditingController();
  final bairroCtrl = TextEditingController();
  final cidadeCtrl = TextEditingController();
  String uf = 'SP';
  final referenciaCtrl = TextEditingController();

  void dispose() {
    cepCtrl.dispose();
    enderecoCtrl.dispose();
    numeroCtrl.dispose();
    complementoCtrl.dispose();
    bairroCtrl.dispose();
    cidadeCtrl.dispose();
    referenciaCtrl.dispose();
  }

  Map<String, dynamic> toMap(String freteId, int ordem) => {
        'frete_id': freteId,
        'ordem': ordem,
        'cep': cepCtrl.text.trim(),
        'endereco': enderecoCtrl.text.trim(),
        'numero': numeroCtrl.text.trim(),
        'complemento': complementoCtrl.text.trim().isEmpty
            ? null
            : complementoCtrl.text.trim(),
        'bairro': bairroCtrl.text.trim(),
        'cidade': cidadeCtrl.text.trim(),
        'uf': uf,
        'referencia': referenciaCtrl.text.trim().isEmpty
            ? null
            : referenciaCtrl.text.trim(),
      };
}

/// Controla os campos de texto de um item do frete.
class ItemControllers {
  final nomeCtrl = TextEditingController();
  final quantidadeCtrl = TextEditingController(text: '1');
  final categoriaCtrl = TextEditingController();
  final observacaoCtrl = TextEditingController();

  void dispose() {
    nomeCtrl.dispose();
    quantidadeCtrl.dispose();
    categoriaCtrl.dispose();
    observacaoCtrl.dispose();
  }

  Map<String, dynamic> toMap(String freteId, int ordem) => {
        'frete_id': freteId,
        'ordem': ordem,
        'nome': nomeCtrl.text.trim(),
        'quantidade': int.tryParse(quantidadeCtrl.text.trim()) ?? 1,
        'categoria': categoriaCtrl.text.trim().isEmpty
            ? null
            : categoriaCtrl.text.trim(),
        'observacao': observacaoCtrl.text.trim().isEmpty
            ? null
            : observacaoCtrl.text.trim(),
      };
}

/// Gerencia o estado de todo o formulário multi-etapas de novo frete.
///
/// Utiliza [ChangeNotifier] para que os widgets escutem mudanças de estado
/// sem depender de pacotes externos de gerenciamento de estado.
class NovoFreteController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Etapa 1 — Dados iniciais
  // ---------------------------------------------------------------------------
  final tituloCtrl = TextEditingController();
  final descricaoCtrl = TextEditingController();
  DateTime? dataDesejada;
  String periodo = '';

  // ---------------------------------------------------------------------------
  // Etapa 2 — Origem
  // ---------------------------------------------------------------------------
  final origemCepCtrl = TextEditingController();
  final origemEnderecoCtrl = TextEditingController();
  final origemNumeroCtrl = TextEditingController();
  final origemComplementoCtrl = TextEditingController();
  final origemBairroCtrl = TextEditingController();
  final origemCidadeCtrl = TextEditingController();
  String origemUf = 'SP';
  final origemReferenciaCtrl = TextEditingController();

  // ---------------------------------------------------------------------------
  // Etapa 3 — Paradas intermediárias
  // ---------------------------------------------------------------------------
  final List<ParadaControllers> paradas = [];

  // ---------------------------------------------------------------------------
  // Etapa 4 — Destino
  // ---------------------------------------------------------------------------
  final destinoCepCtrl = TextEditingController();
  final destinoEnderecoCtrl = TextEditingController();
  final destinoNumeroCtrl = TextEditingController();
  final destinoComplementoCtrl = TextEditingController();
  final destinoBairroCtrl = TextEditingController();
  final destinoCidadeCtrl = TextEditingController();
  String destinoUf = 'SP';
  final destinoReferenciaCtrl = TextEditingController();

  // ---------------------------------------------------------------------------
  // Etapa 5 — Itens
  // ---------------------------------------------------------------------------
  final List<ItemControllers> itens = [ItemControllers()];

  // ---------------------------------------------------------------------------
  // Etapa 6 — Ajudantes
  // ---------------------------------------------------------------------------
  int qtdAjudantes = 0;
  bool precisaMontagem = false;
  bool precisaEmbalagem = false;
  final observacoesGeraisCtrl = TextEditingController();

  // ---------------------------------------------------------------------------
  // Estado assíncrono
  // ---------------------------------------------------------------------------
  bool _loading = false;
  String? _erro;

  bool get loading => _loading;
  String? get erro => _erro;

  // ---------------------------------------------------------------------------
  // Setters com notificação
  // ---------------------------------------------------------------------------

  void setDataDesejada(DateTime? data) {
    dataDesejada = data;
    notifyListeners();
  }

  void setPeriodo(String p) {
    periodo = p;
    notifyListeners();
  }

  void setOrigemUf(String uf) {
    origemUf = uf;
    notifyListeners();
  }

  void setDestinoUf(String uf) {
    destinoUf = uf;
    notifyListeners();
  }

  void setParadaUf(int index, String uf) {
    paradas[index].uf = uf;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Gerenciamento de paradas
  // ---------------------------------------------------------------------------

  void adicionarParada() {
    paradas.add(ParadaControllers());
    notifyListeners();
  }

  void removerParada(int index) {
    paradas[index].dispose();
    paradas.removeAt(index);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Gerenciamento de itens
  // ---------------------------------------------------------------------------

  void adicionarItem() {
    itens.add(ItemControllers());
    notifyListeners();
  }

  void removerItem(int index) {
    if (itens.length <= 1) return;
    itens[index].dispose();
    itens.removeAt(index);
    notifyListeners();
  }

  void setQtdAjudantes(int n) {
    qtdAjudantes = n < 0 ? 0 : n;
    notifyListeners();
  }

  void setPrecisaMontagem(bool v) {
    precisaMontagem = v;
    notifyListeners();
  }

  void setPrecisaEmbalagem(bool v) {
    precisaEmbalagem = v;
    notifyListeners();
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistência
  // ---------------------------------------------------------------------------

  /// Chama o serviço para persistir o frete no Supabase.
  /// Retorna `true` em caso de sucesso; em caso de erro, [erro] é populado.
  Future<bool> salvar(
    Future<String?> Function(NovoFreteController) salvarFn,
  ) async {
    _setLoading(true);
    _erro = null;

    final erro = await salvarFn(this);

    _erro = erro;
    _setLoading(false);
    return erro == null;
  }

  // ---------------------------------------------------------------------------
  // Construção dos mapas para persistência
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toFreteMap(String clienteId) => {
        'cliente_id': clienteId,
        'titulo':
            tituloCtrl.text.trim().isEmpty ? null : tituloCtrl.text.trim(),
        'descricao':
            descricaoCtrl.text.trim().isEmpty ? null : descricaoCtrl.text.trim(),
        'data_desejada': dataDesejada?.toIso8601String().substring(0, 10),
        'periodo': periodo.isEmpty ? null : periodo,
        'origem_cep': origemCepCtrl.text.trim(),
        'origem_endereco': origemEnderecoCtrl.text.trim(),
        'origem_numero': origemNumeroCtrl.text.trim(),
        'origem_complemento': origemComplementoCtrl.text.trim().isEmpty
            ? null
            : origemComplementoCtrl.text.trim(),
        'origem_bairro': origemBairroCtrl.text.trim(),
        'origem_cidade': origemCidadeCtrl.text.trim(),
        'origem_uf': origemUf,
        'origem_referencia': origemReferenciaCtrl.text.trim().isEmpty
            ? null
            : origemReferenciaCtrl.text.trim(),
        'destino_cep': destinoCepCtrl.text.trim(),
        'destino_endereco': destinoEnderecoCtrl.text.trim(),
        'destino_numero': destinoNumeroCtrl.text.trim(),
        'destino_complemento': destinoComplementoCtrl.text.trim().isEmpty
            ? null
            : destinoComplementoCtrl.text.trim(),
        'destino_bairro': destinoBairroCtrl.text.trim(),
        'destino_cidade': destinoCidadeCtrl.text.trim(),
        'destino_uf': destinoUf,
        'destino_referencia': destinoReferenciaCtrl.text.trim().isEmpty
            ? null
            : destinoReferenciaCtrl.text.trim(),
        'qtd_ajudantes': qtdAjudantes,
        'precisa_montagem': precisaMontagem,
        'precisa_embalagem': precisaEmbalagem,
        'observacoes_gerais': observacoesGeraisCtrl.text.trim().isEmpty
            ? null
            : observacoesGeraisCtrl.text.trim(),
        'status': 'aberto',
      };

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    tituloCtrl.dispose();
    descricaoCtrl.dispose();
    origemCepCtrl.dispose();
    origemEnderecoCtrl.dispose();
    origemNumeroCtrl.dispose();
    origemComplementoCtrl.dispose();
    origemBairroCtrl.dispose();
    origemCidadeCtrl.dispose();
    origemReferenciaCtrl.dispose();
    destinoCepCtrl.dispose();
    destinoEnderecoCtrl.dispose();
    destinoNumeroCtrl.dispose();
    destinoComplementoCtrl.dispose();
    destinoBairroCtrl.dispose();
    destinoCidadeCtrl.dispose();
    destinoReferenciaCtrl.dispose();
    observacoesGeraisCtrl.dispose();
    for (final p in paradas) {
      p.dispose();
    }
    for (final i in itens) {
      i.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  @override
  String toString() => 'NovoFreteController('
      'etapa atual gerenciada pela página, '
      'paradas: ${paradas.length}, '
      'itens: ${itens.length}'
      ')';
}
