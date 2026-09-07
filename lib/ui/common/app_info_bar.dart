import 'package:fluent_ui/fluent_ui.dart';

/// Atalhos para as notificações temporárias do Fluent UI, para as telas não
/// repetirem o mesmo `builder` a cada aviso.
void showSuccessBar(BuildContext context, String title, {String? message}) =>
    _show(context, title, message, InfoBarSeverity.success);

void showInfoBarMessage(BuildContext context, String title,
        {String? message}) =>
    _show(context, title, message, InfoBarSeverity.info);

void showErrorBar(BuildContext context, String title, {String? message}) =>
    _show(context, title, message, InfoBarSeverity.error);

void _show(
  BuildContext context,
  String title,
  String? message,
  InfoBarSeverity severity,
) {
  displayInfoBar(
    context,
    builder: (context, close) => InfoBar(
      title: Text(title),
      content: message == null ? null : Text(message),
      severity: severity,
      onClose: close,
    ),
  );
}
