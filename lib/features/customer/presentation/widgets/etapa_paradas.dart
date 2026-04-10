import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/novo_frete_controller.dart';
import 'endereco_form_fields.dart';

/// Etapa 3 — Paradas intermediárias (zero ou mais).
class EtapaParadas extends StatelessWidget {
  const EtapaParadas({
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
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final paradas = controller.paradas;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Paradas intermediárias',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Adicione paradas entre a origem e o destino (opcional).',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (paradas.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.add_location_alt_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhuma parada adicionada',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              for (int i = 0; i < paradas.length; i++) ...[
                _ParadaCard(
                  index: i,
                  parada: paradas[i],
                  controller: controller,
                ),
                const SizedBox(height: 16),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Adicionar parada'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: controller.adicionarParada,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParadaCard extends StatelessWidget {
  const _ParadaCard({
    required this.index,
    required this.parada,
    required this.controller,
  });

  final int index;
  final ParadaControllers parada;
  final NovoFreteController controller;

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
                Text(
                  'Parada ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Remover parada',
                  onPressed: () => controller.removerParada(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EnderecoFormFields(
              cepCtrl: parada.cepCtrl,
              enderecoCtrl: parada.enderecoCtrl,
              numeroCtrl: parada.numeroCtrl,
              complementoCtrl: parada.complementoCtrl,
              bairroCtrl: parada.bairroCtrl,
              cidadeCtrl: parada.cidadeCtrl,
              uf: parada.uf,
              onUfChanged: (v) => controller.setParadaUf(index, v ?? 'SP'),
              referenciaCtrl: parada.referenciaCtrl,
            ),
          ],
        ),
      ),
    );
  }
}
