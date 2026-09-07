import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

/// Botões de minimizar, maximizar e fechar da barra de título customizada.
///
/// A janela usa `titleBarStyle: hidden` (veja `window_setup.dart`), então
/// esses controles precisam ser ligados ao `window_manager` na mão.
class WindowCaptionControls extends StatelessWidget {
  const WindowCaptionControls({super.key, required this.isMaximized});

  /// Estado atual da janela — a tela principal escuta `onWindowMaximize` e
  /// `onWindowUnmaximize` para manter isto atualizado.
  final bool isMaximized;

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WindowCaptionButton.minimize(
          brightness: brightness,
          onPressed: windowManager.minimize,
        ),
        if (isMaximized)
          WindowCaptionButton.unmaximize(
            brightness: brightness,
            onPressed: windowManager.unmaximize,
          )
        else
          WindowCaptionButton.maximize(
            brightness: brightness,
            onPressed: windowManager.maximize,
          ),
        WindowCaptionButton.close(
          brightness: brightness,
          onPressed: windowManager.close,
        ),
      ],
    );
  }
}
