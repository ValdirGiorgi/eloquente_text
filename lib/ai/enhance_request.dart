import '../models/purpose.dart';
import '../models/tone.dart';
import 'prompts/system_prompt.dart';
import 'prompts/user_prompt.dart';

/// Tudo que um provedor precisa para reescrever um texto.
///
/// Os prompts são montados aqui, e não em cada provedor, porque são
/// idênticos para todos — só o formato da requisição HTTP muda de um para
/// outro.
class EnhanceRequest {
  const EnhanceRequest({
    required this.text,
    required this.tone,
    required this.purpose,
    this.temperature,
    this.humanize = false,
  });

  final String text;
  final Tone tone;
  final Purpose purpose;

  /// `null` deixa o provedor usar a temperatura padrão da própria API.
  final double? temperature;

  final bool humanize;

  String get systemPrompt => buildSystemPrompt(humanize: humanize);

  String get userPrompt =>
      buildUserPrompt(text: text, tone: tone, purpose: purpose);
}
