import 'package:flutter/material.dart';

import '../controllers/novo_frete_controller.dart';
import 'endereco_form_fields.dart';

/// Etapa 4 — Endereço de destino / entrega.
class EtapaDestino extends StatelessWidget {
  const EtapaDestino({
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
            'Local de entrega',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Informe o endereço de destino do frete.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) => EnderecoFormFields(
              cepCtrl: controller.destinoCepCtrl,
              enderecoCtrl: controller.destinoEnderecoCtrl,
              numeroCtrl: controller.destinoNumeroCtrl,
              complementoCtrl: controller.destinoComplementoCtrl,
              bairroCtrl: controller.destinoBairroCtrl,
              cidadeCtrl: controller.destinoCidadeCtrl,
              uf: controller.destinoUf,
              onUfChanged: (v) => controller.setDestinoUf(v ?? 'SP'),
              referenciaCtrl: controller.destinoReferenciaCtrl,
            ),
          ),
        ],
      ),
    );
  }
}
