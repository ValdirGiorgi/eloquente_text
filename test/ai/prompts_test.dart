// Testes dos prompts enviados às APIs de IA (lib/ai/prompts/).

import 'package:eloquente_text/ai/prompts/humanizer_instructions.dart';
import 'package:eloquente_text/ai/prompts/system_prompt.dart';
import 'package:eloquente_text/ai/prompts/user_prompt.dart';
import 'package:eloquente_text/models/language.dart';
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
    test('por padrão (sem idioma explícito), reforça que a resposta deve ser em pt-BR', () {
      expect(
        buildSystemPrompt(),
        contains('You are a writing editor'),
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

    test('usa o idioma escolhido na regra e no aviso final', () {
      final spanish = buildSystemPrompt(language: Language.spanish);
      expect(spanish, contains('Always write the rewritten text in Spanish (es)'));
      expect(spanish, contains('your reply must always be in Spanish (es)'));
      expect(spanish, isNot(contains('Brazilian Portuguese')));

      final english = buildSystemPrompt(language: Language.english);
      expect(english, contains('Always write the rewritten text in English (en)'));
      expect(english, contains('your reply must always be in English (en)'));
    });

    test('com humanizar, usa as instruções do idioma escolhido', () {
      final spanish = buildSystemPrompt(
        language: Language.spanish,
        humanize: true,
      );
      expect(spanish, contains('Write the final rewritten text in Spanish (es)'));
      expect(spanish, isNot(contains('Brazilian Portuguese (pt-BR)')));
    });
  });

  group('humanizerInstructionsFor', () {
    test('cada idioma tem exemplos próprios, sem contaminação cruzada', () {
      final pt = humanizerInstructionsFor(Language.portuguese);
      final es = humanizerInstructionsFor(Language.spanish);
      final en = humanizerInstructionsFor(Language.english);

      expect(pt, contains('além disso'));
      expect(pt, isNot(contains('moreover')));

      expect(es, contains('además'));
      expect(es, isNot(contains('além disso')));

      expect(en, contains('moreover'));
      expect(en, isNot(contains('além disso')));
      expect(en, isNot(contains('además')));
    });
  });

  group('Tone, Purpose e Language', () {
    test('recuperam o valor a partir do rótulo gravado', () {
      expect(Tone.fromLabel('Amigável'), Tone.friendly);
      expect(Purpose.fromLabel('WhatsApp'), Purpose.whatsApp);
      expect(Language.fromLabel('Espanhol'), Language.spanish);
    });

    test('devolvem null para rótulos desconhecidos', () {
      expect(Tone.fromLabel('Inexistente'), isNull);
      expect(Purpose.fromLabel(null), isNull);
      expect(Language.fromLabel('Inexistente'), isNull);
    });
  });
}
