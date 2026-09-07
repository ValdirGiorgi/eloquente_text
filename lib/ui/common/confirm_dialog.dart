import 'package:fluent_ui/fluent_ui.dart';

/// Diálogo de confirmação para ações destrutivas (limpar histórico, zerar
/// estatísticas, apagar um item).
///
/// Retorna `true` quando o usuário confirma.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => ContentDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        Button(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style:
              ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
