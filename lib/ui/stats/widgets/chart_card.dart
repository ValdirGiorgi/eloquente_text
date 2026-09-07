import 'package:fluent_ui/fluent_ui.dart';

/// Moldura dos gráficos: título, altura fixa e a borda do tema.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.isEmpty = false,
    this.emptyMessage = 'Sem dados ainda',
  });

  static const double _chartHeight = 300;

  final String title;
  final Widget child;
  final bool isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.typography.subtitle),
        const SizedBox(height: 12),
        Container(
          height: _chartHeight,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.resources.dividerStrokeColorDefault,
            ),
          ),
          child: isEmpty ? Center(child: Text(emptyMessage)) : child,
        ),
      ],
    );
  }
}
