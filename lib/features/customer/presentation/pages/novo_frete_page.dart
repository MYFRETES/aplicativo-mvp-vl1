import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../shared/models/frete_models.dart';
import '../controllers/novo_frete_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Página principal
// ─────────────────────────────────────────────────────────────────────────────

class NovoFretePage extends StatefulWidget {
  const NovoFretePage({super.key});

  @override
  State<NovoFretePage> createState() => _NovoFretePageState();
}

class _NovoFretePageState extends State<NovoFretePage> {
  late final NovoFreteController _controller;
  final _pageController = PageController();
  final _formKeys =
      List.generate(7, (_) => GlobalKey<FormState>());

  static const _stepLabels = [
    'Dados iniciais',
    'Origem',
    'Paradas',
    'Destino',
    'Itens',
    'Ajudantes',
    'Revisão',
  ];

  @override
  void initState() {
    super.initState();
    _controller = NovoFreteController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Navegação ──────────────────────────────────────────────────────────────

  Future<void> _avancar() async {
    final step = _controller.etapaAtual;
    final isReview = step == NovoFreteController.totalEtapas - 1;

    if (!isReview) {
      final valid = _formKeys[step].currentState?.validate() ?? true;
      if (!valid) return;
    }

    if (isReview) {
      await _submeter();
    } else {
      _controller.avancar();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _voltar() {
    if (_controller.etapaAtual > 0) {
      _controller.voltar();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submeter() async {
    final ok = await _controller.submeter();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Frete solicitado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(RouteNames.homeCliente);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final step = _controller.etapaAtual;
        final isReview = step == NovoFreteController.totalEtapas - 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Novo Frete'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _controller.loading ? null : _voltar,
            ),
          ),
          body: Column(
            children: [
              _ProgressHeader(
                step: step,
                total: NovoFreteController.totalEtapas,
                label: _stepLabels[step],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _EtapaDadosIniciais(
                      controller: _controller,
                      formKey: _formKeys[0],
                    ),
                    _EtapaEndereco(
                      key: const ValueKey('origem'),
                      titulo: 'Endereço de Origem (Coleta)',
                      data: _controller.origem,
                      formKey: _formKeys[1],
                    ),
                    _EtapaParadas(
                      controller: _controller,
                      formKey: _formKeys[2],
                    ),
                    _EtapaEndereco(
                      key: const ValueKey('destino'),
                      titulo: 'Endereço de Destino (Entrega)',
                      data: _controller.destino,
                      formKey: _formKeys[3],
                    ),
                    _EtapaItens(
                      controller: _controller,
                      formKey: _formKeys[4],
                    ),
                    _EtapaAjudantes(
                      controller: _controller,
                      formKey: _formKeys[5],
                    ),
                    _EtapaRevisao(
                      controller: _controller,
                      formKey: _formKeys[6],
                    ),
                  ],
                ),
              ),
              if (_controller.erro != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    _controller.erro!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              _BottomButtons(
                step: step,
                total: NovoFreteController.totalEtapas,
                loading: _controller.loading,
                isReview: isReview,
                onVoltar: _voltar,
                onAvancar: _avancar,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares da estrutura da página
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.total,
    required this.label,
  });

  final int step;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (step + 1) / total,
          minHeight: 6,
          backgroundColor: AppColors.border.withOpacity(0.2),
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${step + 1} / $total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.step,
    required this.total,
    required this.loading,
    required this.isReview,
    required this.onVoltar,
    required this.onAvancar,
  });

  final int step;
  final int total;
  final bool loading;
  final bool isReview;
  final VoidCallback onVoltar;
  final VoidCallback onAvancar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? null : onVoltar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: loading ? null : onAvancar,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(isReview ? 'Confirmar e Enviar' : 'Avançar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etapa 0 — Dados iniciais
// ─────────────────────────────────────────────────────────────────────────────

class _EtapaDadosIniciais extends StatefulWidget {
  const _EtapaDadosIniciais({
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  @override
  State<_EtapaDadosIniciais> createState() => _EtapaDadosIniciaisState();
}

class _EtapaDadosIniciaisState extends State<_EtapaDadosIniciais> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _dataCtrl;
  late final TextEditingController _periodoCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _tituloCtrl = TextEditingController(text: c.titulo);
    _descricaoCtrl = TextEditingController(text: c.descricao);
    _periodoCtrl = TextEditingController(text: c.periodo);
    _dataCtrl = TextEditingController(
      text: c.dataDesejada != null
          ? DateFormat('dd/MM/yyyy').format(c.dataDesejada!)
          : '',
    );
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _dataCtrl.dispose();
    _periodoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          widget.controller.dataDesejada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      widget.controller.dataDesejada = picked;
      _dataCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(
              labelText: 'Título (opcional)',
              hintText: 'Ex.: Mudança de apartamento',
            ),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => c.titulo = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoCtrl,
            decoration: const InputDecoration(
              labelText: 'Descrição / Observações',
              hintText: 'Descreva o que precisa ser transportado',
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => c.descricao = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dataCtrl,
            decoration: const InputDecoration(
              labelText: 'Data desejada *',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            readOnly: true,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe a data desejada' : null,
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _periodoCtrl,
            decoration: const InputDecoration(
              labelText: 'Período / Faixa de horário (opcional)',
              hintText: 'Ex.: manhã, entre 8h e 12h',
            ),
            onChanged: (v) => c.periodo = v,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etapa 1 e 3 — Endereço (origem / destino) — widget reutilizável
// ─────────────────────────────────────────────────────────────────────────────

class _EtapaEndereco extends StatefulWidget {
  const _EtapaEndereco({
    super.key,
    required this.titulo,
    required this.data,
    required this.formKey,
  });

  final String titulo;
  final FreteEnderecoData data;
  final GlobalKey<FormState> formKey;

  @override
  State<_EtapaEndereco> createState() => _EtapaEnderecoState();
}

class _EtapaEnderecoState extends State<_EtapaEndereco> {
  late final _EnderecoControllers _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = _EnderecoControllers.from(widget.data);
  }

  @override
  void dispose() {
    _ctrls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.titulo,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _EnderecoFormFields(ctrls: _ctrls, data: widget.data),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etapa 2 — Paradas intermediárias
// ─────────────────────────────────────────────────────────────────────────────

class _EtapaParadas extends StatefulWidget {
  const _EtapaParadas({
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  @override
  State<_EtapaParadas> createState() => _EtapaParadasState();
}

class _EtapaParadasState extends State<_EtapaParadas> {
  final _ctrls = <FreteEnderecoData, _EnderecoControllers>{};

  @override
  void initState() {
    super.initState();
    _syncCtrls();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() => setState(_syncCtrls);

  void _syncCtrls() {
    final paradas = widget.controller.paradas;
    // Remover controllers de paradas que já não existem
    _ctrls.keys
        .where((p) => !paradas.contains(p))
        .toList()
        .forEach((p) {
      _ctrls[p]!.dispose();
      _ctrls.remove(p);
    });
    // Adicionar controllers para novas paradas
    for (final p in paradas) {
      _ctrls.putIfAbsent(p, () => _EnderecoControllers.from(p));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paradas = widget.controller.paradas;

    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (paradas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(Icons.route_outlined,
                      size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    'Sem paradas intermediárias.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Se o frete tiver paradas, adicione-as abaixo.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (int i = 0; i < paradas.length; i++) ...[
            const SizedBox(height: 8),
            _ParadaCard(
              index: i,
              data: paradas[i],
              ctrls: _ctrls[paradas[i]]!,
              onRemover: () =>
                  widget.controller.removerParada(i),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.controller.adicionarParada,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Adicionar parada'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParadaCard extends StatelessWidget {
  const _ParadaCard({
    required this.index,
    required this.data,
    required this.ctrls,
    required this.onRemover,
  });

  final int index;
  final FreteEnderecoData data;
  final _EnderecoControllers ctrls;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Parada ${index + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remover parada',
                  onPressed: onRemover,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _EnderecoFormFields(ctrls: ctrls, data: data),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etapa 4 — Itens do frete
// ─────────────────────────────────────────────────────────────────────────────

class _EtapaItens extends StatefulWidget {
  const _EtapaItens({
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  @override
  State<_EtapaItens> createState() => _EtapaItensState();
}

class _EtapaItensState extends State<_EtapaItens> {
  final _ctrls = <FreteItemData, _ItemControllers>{};

  @override
  void initState() {
    super.initState();
    _syncCtrls();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() => setState(_syncCtrls);

  void _syncCtrls() {
    final itens = widget.controller.itens;
    _ctrls.keys
        .where((item) => !itens.contains(item))
        .toList()
        .forEach((item) {
      _ctrls[item]!.dispose();
      _ctrls.remove(item);
    });
    for (final item in itens) {
      _ctrls.putIfAbsent(item, () => _ItemControllers.from(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.controller.itens;

    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (itens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum item adicionado.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adicione os itens que serão transportados.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (int i = 0; i < itens.length; i++) ...[
            const SizedBox(height: 8),
            _ItemCard(
              index: i,
              data: itens[i],
              ctrls: _ctrls[itens[i]]!,
              onRemover: () => widget.controller.removerItem(i),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.controller.adicionarItem,
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('Adicionar item'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.data,
    required this.ctrls,
    required this.onRemover,
  });

  final int index;
  final FreteItemData data;
  final _ItemControllers ctrls;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Item ${index + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remover item',
                  onPressed: onRemover,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: ctrls.nome,
              decoration: const InputDecoration(labelText: 'Nome / Descrição *'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome do item' : null,
              onChanged: (v) => data.nome = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrls.quantidade,
                    decoration: const InputDecoration(labelText: 'Quantidade *'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Mín. 1';
                      return null;
                    },
                    onChanged: (v) =>
                        data.quantidade = int.tryParse(v) ?? 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: ctrls.categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoria (opcional)',
                      hintText: 'Ex.: móvel',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) => data.categoria = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: ctrls.observacao,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                hintText: 'Ex.: frágil, desmontado',
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => data.observacao = v,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etapa 5 — Ajudantes / apoio
// ─────────────────────────────────────────────────────────────────────────────

class _EtapaAjudantes extends StatefulWidget {
  const _EtapaAjudantes({
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  @override
  State<_EtapaAjudantes> createState() => _EtapaAjudantesState();
}

class _EtapaAjudantesState extends State<_EtapaAjudantes> {
  late final TextEditingController _obsCtrl;

  @override
  void initState() {
    super.initState();
    _obsCtrl = TextEditingController(
        text: widget.controller.observacoesAjudantes);
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Form(
      key: widget.formKey,
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quantidade de ajudantes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantidade de ajudantes',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.outlined(
                            onPressed: c.quantidadeAjudantes > 0
                                ? () => c.setQuantidadeAjudantes(
                                    c.quantidadeAjudantes - 1)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              '${c.quantidadeAjudantes}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ),
                          IconButton.outlined(
                            onPressed: c.quantidadeAjudantes < 10
                                ? () => c.setQuantidadeAjudantes(
                                    c.quantidadeAjudantes + 1)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Serviços adicionais
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Precisa de montagem / desmontagem'),
                      value: c.precisaMontagem,
                      onChanged: c.setMontagem,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Precisa de embalagem'),
                      value: c.precisaEmbalagem,
                      onChanged: c.setEmbalagem,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observações extras (opcional)',
                  hintText: 'Alguma instrução adicional para o motorista?',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => c.observacoesAjudantes = v,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etapa 6 — Revisão final
// ─────────────────────────────────────────────────────────────────────────────

class _EtapaRevisao extends StatelessWidget {
  const _EtapaRevisao({
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final dateStr = c.dataDesejada != null
        ? DateFormat('dd/MM/yyyy').format(c.dataDesejada!)
        : '—';

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Confira os dados antes de enviar',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _ResumoCard(
            titulo: 'Dados gerais',
            icone: Icons.info_outline,
            linhas: [
              if (c.titulo.isNotEmpty) _Linha('Título', c.titulo),
              if (c.descricao.isNotEmpty)
                _Linha('Descrição', c.descricao),
              _Linha('Data desejada', dateStr),
              if (c.periodo.isNotEmpty) _Linha('Período', c.periodo),
            ],
          ),
          const SizedBox(height: 12),
          _ResumoCard(
            titulo: 'Origem',
            icone: Icons.my_location_outlined,
            linhas: _enderecoLinhas(c.origem),
          ),
          if (c.paradas.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResumoCard(
              titulo: 'Paradas (${c.paradas.length})',
              icone: Icons.route_outlined,
              linhas: c.paradas
                  .asMap()
                  .entries
                  .expand((e) => [
                        _Linha('Parada ${e.key + 1}', ''),
                        ..._enderecoLinhas(e.value),
                      ])
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          _ResumoCard(
            titulo: 'Destino',
            icone: Icons.location_on_outlined,
            linhas: _enderecoLinhas(c.destino),
          ),
          if (c.itens.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResumoCard(
              titulo: 'Itens (${c.itens.length})',
              icone: Icons.inventory_2_outlined,
              linhas: c.itens
                  .asMap()
                  .entries
                  .map((e) => _Linha(
                        'Item ${e.key + 1}',
                        '${e.value.nome} × ${e.value.quantidade}'
                            '${e.value.categoria.isNotEmpty ? ' (${e.value.categoria})' : ''}',
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          _ResumoCard(
            titulo: 'Ajudantes / Apoio',
            icone: Icons.people_outline,
            linhas: [
              _Linha('Ajudantes', '${c.quantidadeAjudantes}'),
              _Linha('Montagem/desmontagem',
                  c.precisaMontagem ? 'Sim' : 'Não'),
              _Linha('Embalagem', c.precisaEmbalagem ? 'Sim' : 'Não'),
              if (c.observacoesAjudantes.isNotEmpty)
                _Linha('Observações', c.observacoesAjudantes),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<_Linha> _enderecoLinhas(FreteEnderecoData e) => [
        _Linha('Endereço', '${e.endereco}, ${e.numero}'),
        if (e.complemento.isNotEmpty)
          _Linha('Complemento', e.complemento),
        _Linha('Bairro', e.bairro),
        _Linha('Cidade / UF', '${e.cidade} / ${e.uf}'),
        _Linha('CEP', e.cep),
        if (e.referencia.isNotEmpty)
          _Linha('Referência', e.referencia),
      ];
}

class _Linha {
  const _Linha(this.rotulo, this.valor);
  final String rotulo;
  final String valor;
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({
    required this.titulo,
    required this.icone,
    required this.linhas,
  });

  final String titulo;
  final IconData icone;
  final List<_Linha> linhas;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...linhas.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: l.valor.isEmpty
                    ? Text(
                        l.rotulo,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '${l.rotulo}:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              l.valor,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de campos de endereço (reutilizado em origem, destino e paradas)
// ─────────────────────────────────────────────────────────────────────────────

class _EnderecoFormFields extends StatelessWidget {
  const _EnderecoFormFields({required this.ctrls, required this.data});

  final _EnderecoControllers ctrls;
  final FreteEnderecoData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: ctrls.cep,
          decoration: const InputDecoration(labelText: 'CEP *'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Informe o CEP' : null,
          onChanged: (v) => data.cep = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: ctrls.endereco,
          decoration: const InputDecoration(
            labelText: 'Endereço (rua / avenida) *',
          ),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o endereço' : null,
          onChanged: (v) => data.endereco = v,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: ctrls.numero,
                decoration: const InputDecoration(labelText: 'Número *'),
                keyboardType: TextInputType.text,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                onChanged: (v) => data.numero = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: ctrls.complemento,
                decoration: const InputDecoration(
                  labelText: 'Complemento (opcional)',
                  hintText: 'Apto, bloco…',
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => data.complemento = v,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: ctrls.bairro,
          decoration: const InputDecoration(labelText: 'Bairro *'),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o bairro' : null,
          onChanged: (v) => data.bairro = v,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: ctrls.cidade,
                decoration: const InputDecoration(labelText: 'Cidade *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a cidade'
                    : null,
                onChanged: (v) => data.cidade = v,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: ctrls.uf,
                decoration: const InputDecoration(labelText: 'UF *'),
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                counterText: '',
                validator: (v) =>
                    (v == null || v.length != 2) ? 'Ex.: SP' : null,
                onChanged: (v) => data.uf = v.toUpperCase(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: ctrls.referencia,
          decoration: const InputDecoration(
            labelText: 'Referência (opcional)',
            hintText: 'Ex.: próximo ao shopping',
          ),
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => data.referencia = v,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers: conjuntos de TextEditingController
// ─────────────────────────────────────────────────────────────────────────────

class _EnderecoControllers {
  final cep = TextEditingController();
  final endereco = TextEditingController();
  final numero = TextEditingController();
  final complemento = TextEditingController();
  final bairro = TextEditingController();
  final cidade = TextEditingController();
  final uf = TextEditingController();
  final referencia = TextEditingController();

  _EnderecoControllers();

  factory _EnderecoControllers.from(FreteEnderecoData d) {
    return _EnderecoControllers()
      ..cep.text = d.cep
      ..endereco.text = d.endereco
      ..numero.text = d.numero
      ..complemento.text = d.complemento
      ..bairro.text = d.bairro
      ..cidade.text = d.cidade
      ..uf.text = d.uf
      ..referencia.text = d.referencia;
  }

  void dispose() {
    cep.dispose();
    endereco.dispose();
    numero.dispose();
    complemento.dispose();
    bairro.dispose();
    cidade.dispose();
    uf.dispose();
    referencia.dispose();
  }
}

class _ItemControllers {
  final nome = TextEditingController();
  final quantidade = TextEditingController();
  final categoria = TextEditingController();
  final observacao = TextEditingController();

  _ItemControllers();

  factory _ItemControllers.from(FreteItemData d) {
    return _ItemControllers()
      ..nome.text = d.nome
      ..quantidade.text = d.quantidade.toString()
      ..categoria.text = d.categoria
      ..observacao.text = d.observacao;
  }

  void dispose() {
    nome.dispose();
    quantidade.dispose();
    categoria.dispose();
    observacao.dispose();
  }
}
