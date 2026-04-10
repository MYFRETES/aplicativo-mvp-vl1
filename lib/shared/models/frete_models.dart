/// Modelos simples de dados para o formulário de novo frete.
///
/// São objetos mutáveis propositalmente: os campos são atualizados
/// incrementalmente pelo formulário em etapas, e a imutabilidade
/// seria um overhead desnecessário nessa fase de coleta.

/// Dados de endereço usados para origem, destino e paradas.
class FreteEnderecoData {
  String cep;
  String endereco;
  String numero;
  String complemento;
  String bairro;
  String cidade;
  String uf;
  String referencia;

  FreteEnderecoData({
    this.cep = '',
    this.endereco = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.cidade = '',
    this.uf = '',
    this.referencia = '',
  });

  /// Serializa para mapa de inserção no Supabase, prefixando as colunas.
  Map<String, dynamic> toInsertMap({required String prefix}) => {
        '${prefix}_cep': cep,
        '${prefix}_endereco': endereco,
        '${prefix}_numero': numero,
        '${prefix}_complemento': complemento.isEmpty ? null : complemento,
        '${prefix}_bairro': bairro,
        '${prefix}_cidade': cidade,
        '${prefix}_uf': uf,
        '${prefix}_referencia': referencia.isEmpty ? null : referencia,
      };

  /// Serializa para inserção na tabela `frete_paradas` (sem prefixo).
  Map<String, dynamic> toParadaMap() => {
        'cep': cep,
        'endereco': endereco,
        'numero': numero,
        'complemento': complemento.isEmpty ? null : complemento,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'referencia': referencia.isEmpty ? null : referencia,
      };
}

/// Um item de carga dentro do frete.
class FreteItemData {
  String nome;
  int quantidade;
  String categoria;
  String observacao;

  FreteItemData({
    this.nome = '',
    this.quantidade = 1,
    this.categoria = '',
    this.observacao = '',
  });

  Map<String, dynamic> toInsertMap() => {
        'nome': nome,
        'quantidade': quantidade,
        'categoria': categoria.isEmpty ? null : categoria,
        'observacao': observacao.isEmpty ? null : observacao,
      };
}
