import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_info.dart';
import '../../../core/hotkeys/global_hotkey.dart';

/// Tela "Sobre", aberta pelo menu da barra de título.
void showAppAboutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => ContentDialog(
      title: const Text('Sobre o $kAppName'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '$kAppDescription\n\nAtalho global: $kEnhanceHotkeyLabel',
          ),
          if (kAuthorSiteUrl.isNotEmpty || kAuthorBlogUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Feito por Valdir Giorgi',
              style: FluentTheme.of(
                dialogContext,
              ).typography.caption?.copyWith(
                color: FluentTheme.of(
                  dialogContext,
                ).resources.textFillColorSecondary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kAuthorSiteUrl.isNotEmpty)
                  HyperlinkButton(
                    onPressed: () => launchUrl(Uri.parse(kAuthorSiteUrl)),
                    child: const Text('Site'),
                  ),
                if (kAuthorBlogUrl.isNotEmpty)
                  HyperlinkButton(
                    onPressed: () => launchUrl(Uri.parse(kAuthorBlogUrl)),
                    child: const Text('Blog'),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        // Some enquanto o repositório não estiver publicado.
        if (kRepositoryUrl.isNotEmpty)
          Button(
            onPressed: () => launchUrl(Uri.parse(kRepositoryUrl)),
            child: const Text('Ver repositório'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}
