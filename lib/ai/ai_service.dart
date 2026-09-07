import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import 'ai_provider.dart';
import 'enhance_request.dart';
import 'provider_catalog.dart';

/// Ponto único de entrada usado pela interface: escolhe o provedor, dispara
/// a chamada e devolve a resposta já com o tempo medido (mostrado na tela
/// principal e agregado nas Estatísticas).
class AiService {
  const AiService({this.client});

  /// Injetado apenas nos testes; em produção cada provedor cria o seu.
  final http.Client? client;

  Future<AiResponse> enhance({
    required AiProviderKind providerKind,
    required String apiKey,
    required String model,
    required EnhanceRequest request,
  }) async {
    if (apiKey.isEmpty) {
      throw AiProviderException(
        'API Key não configurada para ${providerKind.label}.',
      );
    }

    final provider = providerKind.create(
      apiKey: apiKey,
      model: model,
      client: client,
    );

    final stopwatch = Stopwatch()..start();
    final response = await provider.enhance(request);
    stopwatch.stop();

    return response.copyWith(responseTime: stopwatch.elapsed);
  }
}
