import 'package:flutter/material.dart';

import '../controllers/novo_frete_controller.dart';
import 'endereco_form_fields.dart';

/// Etapa 2 — Endereço de origem / coleta.
class EtapaOrigem extends StatelessWidget {
  const EtapaOrigem({
    super.key,
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Local de coleta',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Informe o endereço onde o frete será retirado.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) => EnderecoFormFields(
              cepCtrl: controller.origemCepCtrl,
              enderecoCtrl: controller.origemEnderecoCtrl,
              numeroCtrl: controller.origemNumeroCtrl,
              complementoCtrl: controller.origemComplementoCtrl,
              bairroCtrl: controller.origemBairroCtrl,
              cidadeCtrl: controller.origemCidadeCtrl,
              uf: controller.origemUf,
              onUfChanged: (v) => controller.setOrigemUf(v ?? 'SP'),
              referenciaCtrl: controller.origemReferenciaCtrl,
            ),
          ),
        ],
      ),
    );
  }
}
