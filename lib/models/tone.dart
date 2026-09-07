/// Tom de escrita pedido ao modelo.
///
/// Cada tom tem o rótulo em português (mostrado na interface e gravado no
/// histórico) e a tradução em inglês usada no prompt — as instruções são
/// escritas em inglês por serem mais baratas em tokens e seguidas de forma
/// mais confiável pelo modelo.
enum Tone {
  formal('Formal', 'Formal'),
  informal('Informal', 'Informal'),
  technical('Técnico', 'Technical'),
  friendly('Amigável', 'Friendly'),
  persuasive('Persuasivo', 'Persuasive'),
  concise('Conciso', 'Concise'),
  detailed('Detalhado', 'Detailed'),
  neutral('Neutro', 'Neutral'),
  empathetic('Empático', 'Empathetic'),
  assertive('Assertivo', 'Assertive');

  const Tone(this.label, this.promptLabel);

  /// Rótulo em português, exibido na interface e persistido no histórico.
  final String label;

  /// Tradução usada no prompt enviado ao provedor de IA.
  final String promptLabel;

  /// Tom correspondente ao [label] gravado nas configurações/histórico, ou
  /// `null` quando o valor não existe mais (rótulo renomeado, por exemplo).
  static Tone? fromLabel(String? label) {
    for (final tone in values) {
      if (tone.label == label) return tone;
    }
    return null;
  }
}
