import 'dart:async';
import 'dart:io';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// O que o usuário pediu pela bandeja ou pelo atalho global.
enum TrayAction { showWindow, showHistory, showSettings, showStats, capture }

/// Ícone e menu na bandeja do sistema.
///
/// Publica as ações em [actions] em vez de mexer na interface diretamente,
/// para não depender de nenhuma tela específica estar aberta no momento do
/// clique — quem escuta é a [HomePage].
class TrayService with TrayListener {
  TrayService._();

  static final TrayService instance = TrayService._();

  static const String _windowsIcon = 'assets/app_icon.ico';
  static const String _defaultIcon = 'assets/icon/icon.png';

  /// Chave do item de menu -> ação publicada. Adicionar um item é
  /// acrescentar uma entrada aqui e outra em [_buildMenu].
  static const Map<String, TrayAction> _menuActions = {
    'show_window': TrayAction.showWindow,
    'history': TrayAction.showHistory,
    'settings': TrayAction.showSettings,
    'stats': TrayAction.showStats,
  };

  final _controller = StreamController<TrayAction>.broadcast();

  Stream<TrayAction> get actions => _controller.stream;

  Future<void> init() async {
    await trayManager.setIcon(Platform.isWindows ? _windowsIcon : _defaultIcon);
    await trayManager.setContextMenu(_buildMenu());
    trayManager.addListener(this);
  }

  Menu _buildMenu() => Menu(
        items: [
          MenuItem(key: 'show_window', label: 'Melhorar Texto'),
          MenuItem.separator(),
          MenuItem(key: 'history', label: 'Histórico'),
          MenuItem(key: 'settings', label: 'Configurações'),
          MenuItem(key: 'stats', label: 'Estatísticas'),
          MenuItem.separator(),
          MenuItem(key: 'exit', label: 'Sair'),
        ],
      );

  /// Publica uma captura de texto — chamada pelo atalho global, que já
  /// colocou o texto selecionado na área de transferência.
  void requestCapture() => _controller.add(TrayAction.capture);

  @override
  void onTrayIconMouseDown() => _bringToFront(TrayAction.showWindow);

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'exit') {
      await windowManager.destroy();
      exit(0);
    }

    final action = _menuActions[menuItem.key];
    if (action != null) _bringToFront(action);
  }

  void _bringToFront(TrayAction action) {
    windowManager.show();
    windowManager.focus();
    _controller.add(action);
  }

  void dispose() => _controller.close();
}
