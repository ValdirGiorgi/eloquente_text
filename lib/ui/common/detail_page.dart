import 'package:fluent_ui/fluent_ui.dart';

/// Moldura das telas secundárias (Histórico, Configurações, Estatísticas):
/// cabeçalho com título, botão de voltar e uma barra de comandos opcional.
class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.title,
    required this.child,
    this.commands = const [],
  });

  final String title;
  final Widget child;

  /// Botões à direita do cabeçalho (por exemplo, "Limpar Tudo").
  final List<CommandBarItem> commands;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
        commandBar:
            commands.isEmpty ? null : CommandBar(primaryItems: commands),
      ),
      content: child,
    );
  }
}
