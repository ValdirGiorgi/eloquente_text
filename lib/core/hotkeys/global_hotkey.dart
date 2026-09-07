import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../input/selection_capture.dart';
import '../tray/tray_service.dart';

/// Atalho global do app, exibido também na interface e no README.
const String kEnhanceHotkeyLabel = 'Ctrl+Shift+F';

final HotKey _enhanceHotKey = HotKey(
  key: LogicalKeyboardKey.keyF,
  modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
  scope: HotKeyScope.system,
);

/// Registra o atalho global: copia o texto selecionado, traz a janela para
/// frente e pede à [TrayService] que a tela principal carregue a captura.
Future<void> registerEnhanceHotkey() async {
  await hotKeyManager.register(
    _enhanceHotKey,
    keyDownHandler: (_) async {
      await copySelectionToClipboard();
      await _showWindow();
      TrayService.instance.requestCapture();
    },
  );
}

Future<void> _showWindow() async {
  if (await windowManager.isMinimized()) {
    await windowManager.restore();
  }
  await windowManager.show();
  await windowManager.focus();
}
