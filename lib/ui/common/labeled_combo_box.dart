import 'package:fluent_ui/fluent_ui.dart';

/// Seletor rotulado que ocupa toda a largura disponível.
///
/// Existe para as telas não repetirem a combinação
/// `InfoLabel` + `ComboBox` + `isExpanded` a cada campo.
class LabeledComboBox<T> extends StatelessWidget {
  const LabeledComboBox({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;

  /// `null` deixa o seletor vazio (nenhum item cadastrado ainda).
  final T? value;

  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: label,
      child: ComboBox<T>(
        value: value,
        isExpanded: true,
        items: [
          for (final item in items)
            ComboBoxItem(value: item, child: Text(itemLabel(item))),
        ],
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }
}
