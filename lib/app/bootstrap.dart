import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:system_theme/system_theme.dart';

import '../core/hotkeys/global_hotkey.dart';
import '../core/tray/tray_service.dart';
import '../core/window/window_setup.dart';
import '../data/app_database.dart';
import '../data/encryption_service.dart';

/// Inicializa tudo que precisa existir antes da primeira tela abrir.
///
/// A ordem importa: o banco precisa estar aberto antes da criptografia
/// (que só é usada para ler e gravar configurações) e ambos antes de
/// qualquer tela ler uma API key.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.instance.database;
  await EncryptionService.instance.init();
  await _loadSystemAccentColor();
  await TrayService.instance.init();
  await setupMainWindow();
  await registerEnhanceHotkey();
}

/// `system_theme` só suporta estas plataformas; nas demais (Linux, por
/// exemplo) o app usa a cor de destaque padrão do Fluent UI.
Future<void> _loadSystemAccentColor() async {
  final supported = !kIsWeb &&
      (Platform.isWindows ||
          Platform.isAndroid ||
          Platform.isMacOS ||
          Platform.isIOS);
  if (supported) {
    await SystemTheme.accentColor.load();
  }
}
