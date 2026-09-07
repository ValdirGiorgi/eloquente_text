import 'package:fluent_ui/fluent_ui.dart';

import '../../../models/model_config.dart';

/// Lista dos modelos cadastrados, com a temperatura de cada um e o botão de
/// remover.
class ModelList extends StatelessWidget {
  const ModelList({super.key, required this.models, required this.onRemove});

  static const double _height = 200;

  final List<ModelConfig> models;
  final ValueChanged<ModelConfig> onRemove;

  @override
  Widget build(BuildContext context) {
    return Expander(
      header: const Text('Gerenciar Lista'),
      content: SizedBox(
        height: _height,
        child: ListView.builder(
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];
            return ListTile(
              title: Text(model.name),
              subtitle: Text(
                model.temperature == null
                    ? 'Temp: automática'
                    : 'Temp: ${model.temperature}',
              ),
              trailing: IconButton(
                icon: const Icon(FluentIcons.delete, size: 16),
                onPressed: () => onRemove(model),
              ),
            );
          },
        ),
      ),
    );
  }
}
