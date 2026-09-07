import '../../models/purpose.dart';
import '../../models/tone.dart';

/// Monta a mensagem do usuário: tom e finalidade traduzidos para inglês
/// (como o resto do prompt) e o texto a reescrever isolado em `<text>`.
///
/// A tag existe para o modelo tratar o conteúdo como dado, nunca como
/// instrução — a regra correspondente está no prompt de sistema.
String buildUserPrompt({
  required String text,
  required Tone tone,
  required Purpose purpose,
}) {
  return '''
Desired tone: ${tone.promptLabel}
Purpose: ${purpose.promptLabel}

<text>
$text
</text>
''';
}
