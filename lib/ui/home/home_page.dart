import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/app_info.dart';
import '../../core/hotkeys/global_hotkey.dart';
import '../../core/tray/tray_service.dart';
import '../../core/window/window_setup.dart';
import '../common/app_info_bar.dart';
import '../history/history_page.dart';
import '../settings/settings_page.dart';
import '../stats/stats_page.dart';
import 'home_controller.dart';
import 'widgets/app_menu_button.dart';
import 'widgets/enhance_button.dart';
import 'widgets/generation_options.dart';
import 'widgets/humanize_toggle.dart';
import 'widgets/result_footer.dart';
import 'widgets/window_caption_controls.dart';

/// Janela principal: texto de entrada, opções de geração e resultado.
///
/// A lógica fica em [HomeController]; aqui ficam só os widgets, a reação às
/// ações da bandeja e o comportamento da janela.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  final HomeController _controller = HomeController();
  StreamSubscription<TrayAction>? _traySubscription;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _traySubscription = TrayService.instance.actions.listen(_handleTrayAction);
    _controller.loadSettings();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _traySubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // --- Janela ---

  @override
  void onWindowClose() {
    // O X esconde a janela em vez de encerrar o processo (veja
    // `setPreventClose` em window_setup.dart), para o atalho global
    // continuar funcionando com o app "fechado".
    windowManager.hide();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  // --- Bandeja e atalho global ---

  void _handleTrayAction(TrayAction action) {
    if (!mounted) return;
    switch (action) {
      case TrayAction.capture:
        _captureText();
      case TrayAction.showSettings:
        _openPage(const SettingsPage()).then((_) => _controller.loadSettings());
      case TrayAction.showHistory:
        _openPage(const HistoryPage());
      case TrayAction.showStats:
        _openPage(const StatsPage());
      case TrayAction.showWindow:
        break;
    }
  }

  Future<void> _openPage(Widget page) =>
      Navigator.push(context, FluentPageRoute(builder: (_) => page));

  Future<void> _captureText() async {
    if (await _controller.captureFromClipboard() && mounted) {
      showSuccessBar(context, 'Texto capturado!');
    }
  }

  // --- Ações da tela ---

  Future<void> _enhanceText() async {
    final error = await _controller.enhanceText();
    if (error != null && mounted) {
      showErrorBar(context, 'Erro', message: error);
    }
  }

  Future<void> _copyResult() async {
    if (await _controller.copyResult() && mounted) {
      showInfoBarMessage(
        context,
        'Copiado',
        message: 'Texto copiado para a área de transferência.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => NavigationView(
        titleBar: TitleBar(
          isBackButtonVisible: false,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Image.asset('assets/icon/icon.png', width: 16, height: 16),
          ),
          title: const Text(kAppName),
          // A barra de título é desenhada pelo app (a nativa está oculta),
          // então arrastar e maximizar precisam ser ligados na mão.
          onDragStarted: windowManager.startDragging,
          onDoubleTap: toggleMaximize,
          endHeader: AppMenuButton(onSettingsClosed: _controller.loadSettings),
          captionControls: WindowCaptionControls(isMaximized: _isMaximized),
        ),
        content: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _buildInputBox()),
              const SizedBox(height: 16),
              GenerationOptions(controller: _controller),
              const SizedBox(height: 12),
              HumanizeToggle(
                enabled: _controller.humanize,
                onChanged: _controller.setHumanize,
              ),
              const SizedBox(height: 8),
              EnhanceButton(
                isProcessing: _controller.isProcessing,
                onPressed: _enhanceText,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildOutputBox()),
              const SizedBox(height: 8),
              ResultFooter(controller: _controller, onCopy: _copyResult),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox() => TextBox(
        controller: _controller.inputController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        placeholder: 'Cole seu texto aqui ou pressione $kEnhanceHotkeyLabel',
      );

  Widget _buildOutputBox() => TextBox(
        controller: _controller.outputController,
        maxLines: null,
        expands: true,
        readOnly: true,
        textAlignVertical: TextAlignVertical.top,
        placeholder: 'O resultado aparecerá aqui...',
      );
}
