import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/novo_frete_controller.dart';

/// Etapa 1 — Dados iniciais do frete (título, descrição, data, período).
class EtapaDadosIniciais extends StatelessWidget {
  const EtapaDadosIniciais({
    super.key,
    required this.controller,
    required this.formKey,
  });

  final NovoFreteController controller;
  final GlobalKey<FormState> formKey;

  static const _periodos = [
    'Manhã (07h–12h)',
    'Tarde (12h–18h)',
    'Noite (18h–22h)',
    'Qualquer horário',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Dados do frete',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Informe as informações gerais da sua solicitação.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.tituloCtrl,
            decoration: const InputDecoration(
              labelText: 'Título da solicitação (opcional)',
              hintText: 'Ex.: Mudança de apartamento',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.descricaoCtrl,
            decoration: const InputDecoration(
              labelText: 'Observações gerais (opcional)',
              hintText: 'Descreva detalhes relevantes para o motorista',
              alignLabelWithHint: true,
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) {
              final dataSelecionada = controller.dataDesejada;
              return OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  dataSelecionada != null
                      ? DateFormat('dd/MM/yyyy').format(dataSelecionada)
                      : 'Data desejada (opcional)',
                  style: TextStyle(
                    color: dataSelecionada != null
                        ? null
                        : Colors.grey.shade600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  final hoje = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dataSelecionada ?? hoje,
                    firstDate: hoje,
                    lastDate: hoje.add(const Duration(days: 365)),
                  );
                  controller.setDataDesejada(picked);
                },
              );
            },
          ),
          if (controller.dataDesejada != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => controller.setDataDesejada(null),
                child: const Text(
                  'Remover data',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) {
              return DropdownButtonFormField<String>(
                value: controller.periodo.isEmpty ? null : controller.periodo,
                decoration: const InputDecoration(
                    labelText: 'Período preferido (opcional)'),
                items: _periodos
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => controller.setPeriodo(v ?? ''),
              );
            },
          ),
        ],
      ),
    );
  }
}
