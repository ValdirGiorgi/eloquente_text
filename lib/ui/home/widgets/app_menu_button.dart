import 'package:fluent_ui/fluent_ui.dart';

import '../../history/history_page.dart';
import '../../settings/settings_page.dart';
import '../../stats/stats_page.dart';
import 'about_dialog.dart';

/// Menu único da barra de título (Histórico, Estatísticas, Configurações e
/// Sobre), no lugar de vários ícones soltos — um menu compacto é mais
/// familiar em aplicativos desktop.
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key, required this.onSettingsClosed});

  /// Chamado ao voltar das Configurações, onde provedor, modelos e API keys
  /// podem ter mudado.
  final VoidCallback onSettingsClosed;

  @override
  Widget build(BuildContext context) {
    return DropDownButton(
      buttonBuilder: (context, onOpen) => IconButton(
        icon: const Icon(FluentIcons.more_vertical),
        onPressed: onOpen,
      ),
      items: [
        _item(context, FluentIcons.history, 'Histórico', const HistoryPage()),
        _item(
          context,
          FluentIcons.b_i_dashboard,
          'Estatísticas',
          const StatsPage(),
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.settings),
          text: const Text('Configurações'),
          onPressed: () => _afterMenuCloses(() {
            Navigator.push(
              context,
              FluentPageRoute(builder: (_) => const SettingsPage()),
            ).then((_) => onSettingsClosed());
          }),
        ),
        const MenuFlyoutSeparator(),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.info),
          text: const Text('Sobre'),
          onPressed: () => _afterMenuCloses(() => showAppAboutDialog(context)),
        ),
      ],
    );
  }

  MenuFlyoutItem _item(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    return MenuFlyoutItem(
      leading: Icon(icon),
      text: Text(label),
      onPressed: () => _afterMenuCloses(() {
        Navigator.push(context, FluentPageRoute(builder: (_) => page));
      }),
    );
  }

  /// O item do menu fecha o flyout chamando `Navigator.maybePop` e só
  /// depois dispara o callback. Se o callback mexer no Navigator no mesmo
  /// instante (abrir uma página ou um diálogo), as duas ações competem e o
  /// flyout às vezes fica preso atrás da tela seguinte — adiar para depois
  /// do frame atual deixa ele terminar de fechar primeiro.
  void _afterMenuCloses(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }
}
