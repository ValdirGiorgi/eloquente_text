/// Idioma de saída do texto reescrito.
///
/// Mesma convenção de [Tone]/[Purpose]: rótulo em português para a
/// interface/persistência e tradução em inglês usada no prompt.
enum Language {
  portuguese('Português', 'Brazilian Portuguese (pt-BR)'),
  spanish('Espanhol', 'Spanish (es)'),
  english('Inglês', 'English (en)');

  const Language(this.label, this.promptLabel);

  /// Rótulo em português, exibido na interface e persistido nas configurações.
  final String label;

  /// Tradução usada no prompt enviado ao provedor de IA.
  final String promptLabel;

  /// Idioma correspondente ao [label] gravado nas configurações, ou `null`
  /// quando o valor não existe mais (rótulo renomeado, por exemplo).
  static Language? fromLabel(String? label) {
    for (final language in values) {
      if (language.label == label) return language;
    }
    return null;
  }
}
