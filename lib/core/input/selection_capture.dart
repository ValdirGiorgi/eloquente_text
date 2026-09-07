import 'dart:io';

import 'package:flutter/foundation.dart';

/// Copia para a área de transferência o texto selecionado na janela que
/// está em foco — mesmo que seja de outro aplicativo.
///
/// Nenhum sistema operacional expõe por API o texto selecionado em uma
/// janela de terceiros, então o jeito de obtê-lo é simular um Ctrl+C e ler
/// o clipboard em seguida. A espera depois do atalho dá tempo do sistema
/// processar a cópia antes da leitura.
///
/// Falhas são silenciosas de propósito: se o Ctrl+C não puder ser
/// simulado (o `xdotool` não está instalado, por exemplo), o app segue com
/// o que já estiver na área de transferência.
Future<void> copySelectionToClipboard() async {
  try {
    if (Platform.isWindows) {
      await Process.run(
          'powershell',
          [
            '-c',
            r"$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^c')",
          ],
          runInShell: true);
    } else if (Platform.isLinux) {
      // Requer o xdotool instalado (`sudo apt install xdotool`).
      await Process.run('xdotool', ['key', 'ctrl+c']);
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  } catch (error) {
    debugPrint('Não foi possível simular Ctrl+C: $error');
  }
}
