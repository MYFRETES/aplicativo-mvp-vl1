import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/novo_frete_controller.dart';

/// Etapa 7 — Revisão final da solicitação antes do envio.
class EtapaRevisao extends StatelessWidget {
  const EtapaRevisao({super.key, required this.controller});

  final NovoFreteController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Revise sua solicitação',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Confirme os dados antes de enviar.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _ResumoCard(
              titulo: 'Dados do frete',
              icon: Icons.info_outline,
              children: [
                if (controller.tituloCtrl.text.trim().isNotEmpty)
                  _InfoRow(
                      label: 'Título',
                      valor: controller.tituloCtrl.text.trim()),
                if (controller.descricaoCtrl.text.trim().isNotEmpty)
                  _InfoRow(
                      label: 'Observações',
                      valor: controller.descricaoCtrl.text.trim()),
                if (controller.dataDesejada != null)
                  _InfoRow(
                      label: 'Data desejada',
                      valor: DateFormat('dd/MM/yyyy')
                          .format(controller.dataDesejada!)),
                if (controller.periodo.isNotEmpty)
                  _InfoRow(label: 'Período', valor: controller.periodo),
                if (controller.tituloCtrl.text.trim().isEmpty &&
                    controller.descricaoCtrl.text.trim().isEmpty &&
                    controller.dataDesejada == null &&
                    controller.periodo.isEmpty)
                  const _InfoRow(
                      label: '', valor: 'Nenhuma informação adicional.'),
              ],
            ),
            const SizedBox(height: 12),
            _ResumoCard(
              titulo: 'Origem',
              icon: Icons.place_outlined,
              children: [
                _InfoRow(
                    label: 'Endereço',
                    valor:
                        '${controller.origemEnderecoCtrl.text.trim()}, ${controller.origemNumeroCtrl.text.trim()}'),
                if (controller.origemComplementoCtrl.text.trim().isNotEmpty)
                  _InfoRow(
                      label: 'Complemento',
                      valor: controller.origemComplementoCtrl.text.trim()),
                _InfoRow(
                    label: 'Bairro',
                    valor: controller.origemBairroCtrl.text.trim()),
                _InfoRow(
                    label: 'Cidade/UF',
                    valor:
                        '${controller.origemCidadeCtrl.text.trim()} — ${controller.origemUf}'),
                _InfoRow(
                    label: 'CEP',
                    valor: controller.origemCepCtrl.text.trim()),
              ],
            ),
            if (controller.paradas.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ResumoCard(
                titulo: 'Paradas (${controller.paradas.length})',
                icon: Icons.add_location_alt_outlined,
                children: [
                  for (int i = 0; i < controller.paradas.length; i++) ...[
                    _InfoRow(
                        label: 'Parada ${i + 1}',
                        valor:
                            '${controller.paradas[i].enderecoCtrl.text.trim()}, '
                            '${controller.paradas[i].numeroCtrl.text.trim()} — '
                            '${controller.paradas[i].cidadeCtrl.text.trim()}/'
                            '${controller.paradas[i].uf}'),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            _ResumoCard(
              titulo: 'Destino',
              icon: Icons.flag_outlined,
              children: [
                _InfoRow(
                    label: 'Endereço',
                    valor:
                        '${controller.destinoEnderecoCtrl.text.trim()}, ${controller.destinoNumeroCtrl.text.trim()}'),
                if (controller.destinoComplementoCtrl.text.trim().isNotEmpty)
                  _InfoRow(
                      label: 'Complemento',
                      valor: controller.destinoComplementoCtrl.text.trim()),
                _InfoRow(
                    label: 'Bairro',
                    valor: controller.destinoBairroCtrl.text.trim()),
                _InfoRow(
                    label: 'Cidade/UF',
                    valor:
                        '${controller.destinoCidadeCtrl.text.trim()} — ${controller.destinoUf}'),
                _InfoRow(
                    label: 'CEP',
                    valor: controller.destinoCepCtrl.text.trim()),
              ],
            ),
            const SizedBox(height: 12),
            _ResumoCard(
              titulo: 'Itens (${controller.itens.length})',
              icon: Icons.inventory_2_outlined,
              children: [
                for (int i = 0; i < controller.itens.length; i++)
                  _InfoRow(
                      label: 'Item ${i + 1}',
                      valor:
                          '${controller.itens[i].nomeCtrl.text.trim()} × ${controller.itens[i].quantidadeCtrl.text.trim()}'),
              ],
            ),
            const SizedBox(height: 12),
            _ResumoCard(
              titulo: 'Apoio de carga',
              icon: Icons.people_outline,
              children: [
                _InfoRow(
                    label: 'Ajudantes',
                    valor: '${controller.qtdAjudantes}'),
                _InfoRow(
                    label: 'Desmontagem/Montagem',
                    valor: controller.precisaMontagem ? 'Sim' : 'Não'),
                _InfoRow(
                    label: 'Embalagem',
                    valor: controller.precisaEmbalagem ? 'Sim' : 'Não'),
                if (controller.observacoesGeraisCtrl.text.trim().isNotEmpty)
                  _InfoRow(
                      label: 'Observações',
                      valor: controller.observacoesGeraisCtrl.text.trim()),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ao confirmar, sua solicitação ficará disponível para '
                      'motoristas fazerem propostas.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({
    required this.titulo,
    required this.icon,
    required this.children,
  });

  final String titulo;
  final IconData icon;
  final List<Widget> children;

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
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 130,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
