import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/novo_frete_controller.dart';

/// Etapa 6 — Ajudantes e apoio de carga.
class EtapaAjudantes extends StatelessWidget {
  const EtapaAjudantes({
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
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Apoio de carga',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Informe se precisa de ajudantes ou serviços extras.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Quantidade de ajudantes
              Text(
                'Ajudantes necessários',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onPressed: controller.qtdAjudantes > 0
                        ? () => controller
                            .setQtdAjudantes(controller.qtdAjudantes - 1)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${controller.qtdAjudantes}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  _CounterButton(
                    icon: Icons.add,
                    onPressed: () =>
                        controller.setQtdAjudantes(controller.qtdAjudantes + 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Desmontagem / Montagem
              Card(
                child: SwitchListTile(
                  title: const Text('Precisa de desmontagem/montagem?'),
                  subtitle: const Text(
                    'Ex.: móveis, estantes, camas',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: controller.precisaMontagem,
                  onChanged: controller.setPrecisaMontagem,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Embalagem
              Card(
                child: SwitchListTile(
                  title: const Text('Precisa de embalagem?'),
                  subtitle: const Text(
                    'Ex.: caixas, plástico bolha, proteção especial',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: controller.precisaEmbalagem,
                  onChanged: controller.setPrecisaEmbalagem,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Observações gerais
              TextFormField(
                controller: controller.observacoesGeraisCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observações extras (opcional)',
                  hintText:
                      'Informações adicionais para o motorista ou ajudante',
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? AppColors.primary : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
