import 'package:fluent_ui/fluent_ui.dart';

/// Formulário para cadastrar um modelo do provedor selecionado.
///
/// O nome é digitado livremente de propósito: assim modelos lançados depois
/// desta versão do app funcionam sem precisar de atualização.
class ModelForm extends StatelessWidget {
  const ModelForm({
    super.key,
    required this.nameController,
    required this.temperatureController,
    required this.onAdd,
  });

  final TextEditingController nameController;
  final TextEditingController temperatureController;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: InfoLabel(
                label: 'Novo Modelo',
                child: TextBox(
                  controller: nameController,
                  placeholder: 'ex: gpt-4o',
                  onSubmitted: (_) => onAdd(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoLabel(
                label: 'Temp (Op.)',
                child: TextBox(
                  controller: temperatureController,
                  placeholder: '0.7',
                  onSubmitted: (_) => onAdd(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Button(onPressed: onAdd, child: const Text('Adicionar')),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Deixe a temperatura vazia para usar o padrão da API.',
          style: TextStyle(
            fontSize: 11,
            color: FluentTheme.of(context).resources.textFillColorSecondary,
          ),
        ),
      ],
    );
  }
}
