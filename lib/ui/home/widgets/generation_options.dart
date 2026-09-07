import 'package:fluent_ui/fluent_ui.dart';

import '../../../ai/provider_catalog.dart';
import '../../../models/purpose.dart';
import '../../../models/tone.dart';
import '../../common/labeled_combo_box.dart';
import '../home_controller.dart';

/// Painel recolhível com provedor, modelo, tom e finalidade.
///
/// Fica fechado por padrão: o fluxo comum é capturar um texto e clicar em
/// "Melhorar Texto" com as escolhas da última vez, que ficam salvas.
class GenerationOptions extends StatelessWidget {
  const GenerationOptions({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Expander(
      header: const Text('Opções de Geração'),
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LabeledComboBox<AiProviderKind>(
                  label: 'Provedor',
                  value: controller.provider,
                  items: AiProviderKind.values,
                  itemLabel: (provider) => provider.label,
                  onChanged: controller.selectProvider,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabeledComboBox<String>(
                  label: 'Modelo',
                  value: controller.selectedModel.isEmpty
                      ? null
                      : controller.selectedModel,
                  items: controller.availableModels,
                  itemLabel: (model) => model,
                  onChanged: controller.selectModel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LabeledComboBox<Tone>(
                  label: 'Tom',
                  value: controller.tone,
                  items: Tone.values,
                  itemLabel: (tone) => tone.label,
                  onChanged: controller.selectTone,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabeledComboBox<Purpose>(
                  label: 'Finalidade',
                  value: controller.purpose,
                  items: Purpose.values,
                  itemLabel: (purpose) => purpose.label,
                  onChanged: controller.selectPurpose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
