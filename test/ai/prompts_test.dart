// Testes dos prompts enviados às APIs de IA (lib/ai/prompts/).

import 'package:eloquente_text/ai/prompts/system_prompt.dart';
import 'package:eloquente_text/ai/prompts/user_prompt.dart';
import 'package:eloquente_text/models/purpose.dart';
import 'package:eloquente_text/models/tone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildUserPrompt', () {
    test('traduz tom e finalidade e isola o texto em <text>', () {
      final prompt = buildUserPrompt(
        text: 'Preciso de uma revisão.',
        tone: Tone.technical,
        purpose: Purpose.professionalEmail,
      );

      expect(prompt, contains('Desired tone: Technical'));
      expect(prompt, contains('Purpose: Professional email'));
      expect(prompt, contains('<text>\nPreciso de uma revisão.\n</text>'));
    });
  });

  group('buildSystemPrompt', () {
    test('sempre reforça que a resposta deve ser em pt-BR', () {
      expect(
        buildSystemPrompt(),
        contains('Brazilian Portuguese writing editor'),
      );
      expect(buildSystemPrompt(), contains('Brazilian Portuguese (pt-BR)'));
      expect(
        buildSystemPrompt(humanize: true),
        contains('Brazilian Portuguese (pt-BR)'),
      );
    });

    test('sem humanizar, não inclui as instruções do modo Humanizar', () {
      expect(buildSystemPrompt(), isNot(contains('Humanize mode')));
    });

    test('com humanizar, anexa as 35 categorias', () {
      final prompt = buildSystemPrompt(humanize: true);

      expect(prompt, contains('## Humanize mode'));
      expect(prompt, contains('Overuse of em/en dashes'));
    });
  });

  group('Tone e Purpose', () {
    test('recuperam o valor a partir do rótulo gravado', () {
      expect(Tone.fromLabel('Amigável'), Tone.friendly);
      expect(Purpose.fromLabel('WhatsApp'), Purpose.whatsApp);
    });

    test('devolvem null para rótulos desconhecidos', () {
      expect(Tone.fromLabel('Inexistente'), isNull);
      expect(Purpose.fromLabel(null), isNull);
    });
  });
}
