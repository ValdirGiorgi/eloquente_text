// Testes de montagem da requisição e leitura da resposta de cada provedor,
// com um cliente HTTP falso — nenhuma chamada real de rede acontece aqui.

import 'dart:convert';

import 'package:eloquente_text/ai/ai_provider.dart';
import 'package:eloquente_text/ai/ai_service.dart';
import 'package:eloquente_text/ai/enhance_request.dart';
import 'package:eloquente_text/ai/provider_catalog.dart';
import 'package:eloquente_text/models/purpose.dart';
import 'package:eloquente_text/models/tone.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _request = EnhanceRequest(
  text: 'oi tudo bem',
  tone: Tone.formal,
  purpose: Purpose.professionalEmail,
);

/// Cliente falso que responde sempre com [body] e guarda a requisição
/// recebida para as verificações.
class _FakeApi {
  http.Request? lastRequest;

  MockClient respondWith(Object body, {int statusCode = 200}) {
    return MockClient((request) async {
      lastRequest = request;
      return http.Response(
        jsonEncode(body),
        statusCode,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
  }

  Map<String, dynamic> get sentBody =>
      jsonDecode(lastRequest!.body) as Map<String, dynamic>;
}

void main() {
  group('provedores compatíveis com a OpenAI', () {
    test('lê texto, tokens e cache da resposta', () async {
      final api = _FakeApi();
      final provider = AiProviderKind.openAi.create(
        apiKey: 'chave',
        model: 'gpt-4o',
        client: api.respondWith({
          'choices': [
            {
              'message': {'content': '  Bom dia, tudo bem?  '},
            },
          ],
          'usage': {
            'prompt_tokens': 120,
            'completion_tokens': 30,
            'prompt_tokens_details': {'cached_tokens': 60},
          },
        }),
      );

      final response = await provider.enhance(_request);

      expect(response.text, 'Bom dia, tudo bem?');
      expect(response.inputTokens, 120);
      expect(response.outputTokens, 30);
      expect(response.cachedInputTokens, 60);
      expect(response.cacheHitPercentage, 50);
      expect(api.lastRequest!.headers['Authorization'], 'Bearer chave');
      expect(api.sentBody['model'], 'gpt-4o');
    });

    test('lê o campo de cache próprio da DeepSeek', () async {
      final api = _FakeApi();
      final provider = AiProviderKind.deepSeek.create(
        apiKey: 'chave',
        model: '',
        client: api.respondWith({
          'choices': [
            {
              'message': {'content': 'texto'},
            },
          ],
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 5,
            'prompt_cache_hit_tokens': 4,
          },
        }),
      );

      final response = await provider.enhance(_request);

      expect(response.cachedInputTokens, 4);
      // Modelo vazio cai no padrão do provedor.
      expect(api.sentBody['model'], 'deepseek-chat');
    });

    test('omite a temperatura quando ela não foi configurada', () async {
      final api = _FakeApi();
      final provider = AiProviderKind.openAi.create(
        apiKey: 'chave',
        model: 'gpt-4o',
        client: api.respondWith({
          'choices': [
            {
              'message': {'content': 'texto'},
            },
          ],
        }),
      );

      await provider.enhance(_request);
      expect(api.sentBody.containsKey('temperature'), isFalse);
    });
  });

  group('AnthropicProvider', () {
    test('marca o prompt de sistema para cache e lê os tokens lidos', () async {
      final api = _FakeApi();
      final provider = AiProviderKind.anthropic.create(
        apiKey: 'chave',
        model: 'claude-sonnet-5',
        client: api.respondWith({
          'content': [
            {'text': 'Bom dia.'},
          ],
          'usage': {
            'input_tokens': 200,
            'output_tokens': 20,
            'cache_read_input_tokens': 150,
          },
        }),
      );

      final response = await provider.enhance(_request);

      expect(response.text, 'Bom dia.');
      expect(response.cachedInputTokens, 150);
      expect(api.lastRequest!.headers['x-api-key'], 'chave');
      final system = api.sentBody['system'] as List;
      expect(system.first['cache_control'], {'type': 'ephemeral'});
    });
  });

  group('GeminiProvider', () {
    test('autentica pela query string e lê o uso', () async {
      final api = _FakeApi();
      final provider = AiProviderKind.gemini.create(
        apiKey: 'chave',
        model: 'gemini-2.0-flash',
        client: api.respondWith({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Bom dia.'},
                ],
              },
            },
          ],
          'usageMetadata': {'promptTokenCount': 40, 'candidatesTokenCount': 10},
        }),
      );

      final response = await provider.enhance(_request);

      expect(response.text, 'Bom dia.');
      expect(response.inputTokens, 40);
      expect(response.outputTokens, 10);
      expect(response.cachedInputTokens, 0);
      expect(api.lastRequest!.url.queryParameters['key'], 'chave');
    });

    test('erro claro quando a resposta não traz alternativas', () async {
      final api = _FakeApi();
      final provider = AiProviderKind.gemini.create(
        apiKey: 'chave',
        model: '',
        client: api.respondWith({'candidates': <dynamic>[]}),
      );

      expect(
        () => provider.enhance(_request),
        throwsA(isA<AiProviderException>()),
      );
    });
  });

  group('AiService', () {
    test('mede o tempo de resposta', () async {
      final api = _FakeApi();
      final service = AiService(
        client: api.respondWith({
          'choices': [
            {
              'message': {'content': 'texto'},
            },
          ],
        }),
      );

      final response = await service.enhance(
        providerKind: AiProviderKind.openAi,
        apiKey: 'chave',
        model: 'gpt-4o',
        request: _request,
      );

      expect(response.responseTime, greaterThan(Duration.zero));
    });

    test('recusa a chamada sem API key configurada', () {
      expect(
        () => const AiService().enhance(
          providerKind: AiProviderKind.openAi,
          apiKey: '',
          model: 'gpt-4o',
          request: _request,
        ),
        throwsA(
          isA<AiProviderException>().having(
            (e) => e.message,
            'message',
            contains('API Key não configurada'),
          ),
        ),
      );
    });

    test('propaga o status de erro do provedor', () {
      final api = _FakeApi();
      final service = AiService(
        client: api.respondWith({'error': 'invalid key'}, statusCode: 401),
      );

      expect(
        () => service.enhance(
          providerKind: AiProviderKind.openAi,
          apiKey: 'errada',
          model: '',
          request: _request,
        ),
        throwsA(
          isA<AiProviderException>().having(
            (e) => e.message,
            'message',
            contains('401'),
          ),
        ),
      );
    });
  });
}
