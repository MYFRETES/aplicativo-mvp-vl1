import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/services/frete_service.dart';
import '../controllers/novo_frete_controller.dart';
import '../widgets/etapa_ajudantes.dart';
import '../widgets/etapa_dados_iniciais.dart';
import '../widgets/etapa_destino.dart';
import '../widgets/etapa_itens.dart';
import '../widgets/etapa_origem.dart';
import '../widgets/etapa_paradas.dart';
import '../widgets/etapa_revisao.dart';
import '../widgets/step_indicator.dart';

/// Fluxo multi-etapas para o cliente criar uma nova solicitação de frete.
///
/// Gerencia:
/// - navegação entre etapas
/// - validação por etapa via [Form]/[GlobalKey]
/// - envio final ao Supabase via [FreteService]
class NovoFretePage extends StatefulWidget {
  const NovoFretePage({super.key});

  @override
  State<NovoFretePage> createState() => _NovoFretePageState();
}

class _NovoFretePageState extends State<NovoFretePage> {
  late final NovoFreteController _controller;
  late final FreteService _service;

  // Uma chave por etapa com formulário (etapas 0–5); etapa 6 é só revisão.
  final _formKeys = List.generate(6, (_) => GlobalKey<FormState>());

  int _etapaAtual = 0;
  static const int _totalEtapas = 7;

  @override
  void initState() {
    super.initState();
    _controller = NovoFreteController();
    _service = FreteService();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navegação
  // ---------------------------------------------------------------------------

  bool _validarEtapaAtual() {
    if (_etapaAtual < _formKeys.length) {
      return _formKeys[_etapaAtual].currentState?.validate() ?? true;
    }
    return true; // etapa de revisão não tem validação de form
  }

  void _avancar() {
    if (_validarEtapaAtual()) {
      setState(() => _etapaAtual++);
    }
  }

  void _voltar() {
    setState(() => _etapaAtual--);
  }

  Future<void> _confirmar() async {
    final ok = await _controller.salvar(_service.salvarFrete);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação de frete enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.erro ?? 'Erro ao enviar. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nova solicitação'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            StepIndicator(
              etapaAtual: _etapaAtual,
              totalEtapas: _totalEtapas,
            ),
            Expanded(child: _buildEtapaAtual()),
            _buildBarraDeNavegacao(),
          ],
        ),
      );
  }

  Widget _buildEtapaAtual() {
    switch (_etapaAtual) {
      case 0:
        return EtapaDadosIniciais(
          controller: _controller,
          formKey: _formKeys[0],
        );
      case 1:
        return EtapaOrigem(
          controller: _controller,
          formKey: _formKeys[1],
        );
      case 2:
        return EtapaParadas(
          controller: _controller,
          formKey: _formKeys[2],
        );
      case 3:
        return EtapaDestino(
          controller: _controller,
          formKey: _formKeys[3],
        );
      case 4:
        return EtapaItens(
          controller: _controller,
          formKey: _formKeys[4],
        );
      case 5:
        return EtapaAjudantes(
          controller: _controller,
          formKey: _formKeys[5],
        );
      case 6:
        return EtapaRevisao(controller: _controller);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBarraDeNavegacao() {
    final isUltimaEtapa = _etapaAtual == _totalEtapas - 1;

    return ListenableBuilder(
      listenable: _controller,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                if (_etapaAtual > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _controller.loading ? null : _voltar,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Anterior'),
                    ),
                  ),
                if (_etapaAtual > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: isUltimaEtapa
                      ? ElevatedButton(
                          onPressed:
                              _controller.loading ? null : _confirmar,
                          child: _controller.loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Confirmar envio'),
                        )
                      : ElevatedButton(
                          onPressed:
                              _controller.loading ? null : _avancar,
                          child: const Text('Próximo'),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
