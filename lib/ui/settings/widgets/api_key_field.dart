import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ai/provider_catalog.dart';

/// Campo da API key do provedor selecionado, com link para a página onde
/// ela é gerada.
///
/// A chave é gravada criptografada (veja `encryption_service.dart`) e nunca
/// sai do computador do usuário — só é enviada ao provedor escolhido.
class ApiKeyField extends StatelessWidget {
  const ApiKeyField({
    super.key,
    required this.controller,
    required this.provider,
  });

  final TextEditingController controller;
  final AiProviderKind provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoLabel(
          label: 'API Key',
          child: PasswordBox(
            controller: controller,
            placeholder: 'Cole aqui sua chave de ${provider.label}',
            revealMode: PasswordRevealMode.peek,
          ),
        ),
        HyperlinkButton(
          onPressed: () => launchUrl(Uri.parse(provider.apiKeyUrl)),
          child: Text(
            'Obter uma chave em ${provider.apiKeyUrl}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
