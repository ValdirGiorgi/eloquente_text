import 'package:fluent_ui/fluent_ui.dart';

import '../../ai/provider_catalog.dart';

/// Cor fixa de cada provedor nos gráficos e listas de estatísticas.
Color colorForProvider(AiProviderKind? provider) => switch (provider) {
      AiProviderKind.openAi => Colors.green,
      AiProviderKind.deepSeek => Colors.purple,
      AiProviderKind.anthropic => Colors.orange,
      AiProviderKind.gemini => Colors.blue,
      // Provedor removido do app mas ainda presente nos dados históricos.
      null => Colors.grey,
    };

/// Versão que parte do rótulo gravado no banco.
Color colorForProviderLabel(String label) =>
    colorForProvider(AiProviderKind.fromLabel(label));
