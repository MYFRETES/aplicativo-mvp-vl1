import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Indicador visual de progresso por etapas do formulário.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.etapaAtual,
    required this.totalEtapas,
  });

  final int etapaAtual;
  final int totalEtapas;

  static const _rotulos = [
    'Dados',
    'Origem',
    'Paradas',
    'Destino',
    'Itens',
    'Apoio',
    'Revisão',
  ];

  @override
  Widget build(BuildContext context) {
    final rotulo = etapaAtual < _rotulos.length ? _rotulos[etapaAtual] : '';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (etapaAtual + 1) / totalEtapas,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Etapa ${etapaAtual + 1} de $totalEtapas',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
