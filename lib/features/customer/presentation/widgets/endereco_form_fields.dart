import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Campos de endereço reutilizáveis (origem, destino e paradas).
///
/// Recebe os [TextEditingController]s e os callbacks de UF externamente,
/// tornando o widget reutilizável em qualquer etapa.
///
/// É `StatefulWidget` para garantir que cada instância tenha seu próprio
/// [MaskTextInputFormatter] para o campo de CEP (o formatter mantém estado).
class EnderecoFormFields extends StatefulWidget {
  const EnderecoFormFields({
    super.key,
    required this.cepCtrl,
    required this.enderecoCtrl,
    required this.numeroCtrl,
    required this.complementoCtrl,
    required this.bairroCtrl,
    required this.cidadeCtrl,
    required this.uf,
    required this.onUfChanged,
    required this.referenciaCtrl,
  });

  final TextEditingController cepCtrl;
  final TextEditingController enderecoCtrl;
  final TextEditingController numeroCtrl;
  final TextEditingController complementoCtrl;
  final TextEditingController bairroCtrl;
  final TextEditingController cidadeCtrl;
  final String uf;
  final void Function(String?) onUfChanged;
  final TextEditingController referenciaCtrl;

  static const _ufs = [
    'AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MG', 'MS', 'MT', 'PA', 'PB', 'PE', 'PI', 'PR', 'RJ', 'RN',
    'RO', 'RR', 'RS', 'SC', 'SE', 'SP', 'TO',
  ];

  @override
  State<EnderecoFormFields> createState() => _EnderecoFormFieldsState();
}

class _EnderecoFormFieldsState extends State<EnderecoFormFields> {
  late final MaskTextInputFormatter _cepMask;

  @override
  void initState() {
    super.initState();
    _cepMask = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {'#': RegExp(r'\d')},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.cepCtrl,
          decoration: const InputDecoration(labelText: 'CEP *'),
          keyboardType: TextInputType.number,
          inputFormatters: [_cepMask],
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o CEP.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: widget.enderecoCtrl,
          decoration: const InputDecoration(labelText: 'Endereço *'),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o endereço.' : null,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.numeroCtrl,
                decoration: const InputDecoration(labelText: 'Número *'),
                keyboardType: TextInputType.text,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório.' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: widget.complementoCtrl,
                decoration: const InputDecoration(labelText: 'Complemento'),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: widget.bairroCtrl,
          decoration: const InputDecoration(labelText: 'Bairro *'),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o bairro.' : null,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: widget.cidadeCtrl,
                decoration: const InputDecoration(labelText: 'Cidade *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a cidade.' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: widget.uf,
                decoration: const InputDecoration(labelText: 'UF *'),
                isExpanded: true,
                items: EnderecoFormFields._ufs
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: widget.onUfChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: widget.referenciaCtrl,
          decoration: const InputDecoration(
              labelText: 'Ponto de referência (opcional)'),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
