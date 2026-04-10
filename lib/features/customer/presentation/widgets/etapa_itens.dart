import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/novo_frete_controller.dart';

/// Etapa 5 — Itens do frete (lista dinâmica).
class EtapaItens extends StatelessWidget {
  const EtapaItens({
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
          final itens = controller.itens;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Itens do frete',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Liste o que será transportado.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < itens.length; i++) ...[
                _ItemCard(
                  index: i,
                  item: itens[i],
                  podeRemover: itens.length > 1,
                  onRemover: () => controller.removerItem(i),
                ),
                const SizedBox(height: 16),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Adicionar item'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: controller.adicionarItem,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.item,
    required this.podeRemover,
    required this.onRemover,
  });

  final int index;
  final ItemControllers item;
  final bool podeRemover;
  final VoidCallback onRemover;

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
                  'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (podeRemover)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    tooltip: 'Remover item',
                    onPressed: onRemover,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: item.nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome / descrição *',
                hintText: 'Ex.: Sofá de 3 lugares',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome do item.' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.quantidadeCtrl,
                    decoration: const InputDecoration(labelText: 'Qtd. *'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Mín. 1';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: item.categoriaCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Categoria (opcional)'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.observacaoCtrl,
              decoration:
                  const InputDecoration(labelText: 'Observação (opcional)'),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
