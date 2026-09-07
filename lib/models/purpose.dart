/// Finalidade do texto: define o formato e o registro esperados na
/// reescrita (e-mail, mensagem curta, relatório...).
///
/// Segue a mesma convenção de [Tone]: rótulo em português para a interface
/// e tradução em inglês para o prompt.
enum Purpose {
  professionalEmail('E-mail Profissional', 'Professional email'),
  personalEmail('E-mail Pessoal', 'Personal email'),
  whatsApp('WhatsApp', 'WhatsApp message'),
  chat('Telegram/Slack', 'Telegram/Slack message'),
  supportTicket('Abertura de Chamado', 'Support ticket'),
  linkedIn('LinkedIn', 'LinkedIn post'),
  documentation('Documentação', 'Documentation'),
  report('Relatório', 'Report'),
  presentation('Apresentação', 'Presentation slides'),
  meetingMinutes('Ata de Reunião', 'Meeting minutes'),
  quickReply('Resposta Rápida', 'Quick reply'),
  sms('Mensagem SMS', 'SMS message'),
  aiPrompt('Prompt de IA', 'AI prompt');

  const Purpose(this.label, this.promptLabel);

  /// Rótulo em português, exibido na interface e persistido no histórico.
  final String label;

  /// Tradução usada no prompt enviado ao provedor de IA.
  final String promptLabel;

  static Purpose? fromLabel(String? label) {
    for (final purpose in values) {
      if (purpose.label == label) return purpose;
    }
    return null;
  }
}
