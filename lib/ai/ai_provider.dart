import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import 'enhance_request.dart';

/// Erro de uma chamada a um provedor de IA, com a mensagem já pronta para
/// ser mostrada na interface.
class AiProviderException implements Exception {
  const AiProviderException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contrato comum a todo provedor de IA suportado pelo app.
///
/// Para adicionar um provedor novo: crie uma subclasse em
/// `lib/ai/providers/`, implemente [enhance] e registre-a em
/// [AiProviderKind] (`lib/ai/provider_catalog.dart`).
abstract class AiProvider {
  AiProvider({required this.apiKey, required this.model, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;

  /// Modelo escolhido pelo usuário; vazio significa "use o [defaultModel]".
  final String model;

  final http.Client _client;

  /// Nome do provedor nas mensagens de erro.
  String get label;

  /// Modelo usado quando o usuário não cadastrou nenhum.
  String get defaultModel;

  String get effectiveModel => model.isEmpty ? defaultModel : model;

  Future<AiResponse> enhance(EnhanceRequest request);

  /// POST de JSON com o tratamento de erro e a decodificação em UTF-8 que
  /// todos os provedores compartilham.
  ///
  /// A decodificação explícita de `bodyBytes` é necessária: sem ela o
  /// `http` assume latin-1 quando o provedor não declara o charset, e os
  /// acentos do texto em português chegam corrompidos.
  Future<Map<String, dynamic>> postJson({
    required Uri url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json', ...headers},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw AiProviderException(
        '$label: erro ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// Lê um inteiro de um bloco de uso de tokens que pode vir ausente ou
  /// nulo, tentando as chaves na ordem informada (provedores mudam o nome
  /// do campo entre si e entre versões da API).
  static int readTokenCount(Object? usage, List<String> keys) {
    if (usage is! Map) return 0;
    for (final key in keys) {
      final value = usage[key];
      if (value is num) return value.toInt();
    }
    return 0;
  }
}
