import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/app_info.dart';

const Size _initialWindowSize = Size(900, 700);

/// Prepara a janela principal e a exibe.
///
/// A barra de título nativa fica oculta porque o app desenha a própria
/// (veja `TitleBar` em `lib/ui/home/home_page.dart`), e `setPreventClose`
/// faz o botão X cair no `onWindowClose` da tela principal — que esconde a
/// janela em vez de encerrar o processo, para o atalho global continuar
/// funcionando com o app "fechado".
Future<void> setupMainWindow() async {
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: _initialWindowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: kAppName,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
  });
}

/// Alterna entre janela maximizada e restaurada (duplo clique na barra de
/// título customizada).
Future<void> toggleMaximize() async {
  if (await windowManager.isMaximized()) {
    await windowManager.unmaximize();
  } else {
    await windowManager.maximize();
  }
}
