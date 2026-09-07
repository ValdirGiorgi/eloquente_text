import 'package:fluent_ui/fluent_ui.dart';

import '../../data/history_repository.dart';
import '../../models/history_entry.dart';
import '../common/app_info_bar.dart';
import '../common/confirm_dialog.dart';
import '../common/detail_page.dart';
import 'widgets/history_entry_tile.dart';

/// Lista os últimos processamentos, com busca no texto original e no
/// melhorado.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryRepository _repository = HistoryRepository();
  final TextEditingController _searchController = TextEditingController();

  List<HistoryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await _repository.recent();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _clearAll() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Limpar Histórico',
      message:
          'Tem certeza que deseja apagar todo o histórico? As estatísticas '
          'de uso não são afetadas.',
      confirmLabel: 'Apagar',
    );
    if (!confirmed) return;

    await _repository.clear();
    await _load();
    if (mounted) showSuccessBar(context, 'Histórico limpo.');
  }

  Future<void> _delete(HistoryEntry entry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Apagar Item',
      message: 'Deseja apagar este item do histórico?',
      confirmLabel: 'Apagar',
    );
    if (!confirmed) return;

    await _repository.delete(entry.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final visible = _entries.where((entry) => entry.matches(query)).toList();

    return DetailPage(
      title: 'Histórico',
      commands: [
        CommandBarButton(
          icon: const Icon(FluentIcons.delete),
          label: const Text('Limpar Tudo'),
          onPressed: _clearAll,
        ),
      ],
      child: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildList(visible)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextBox(
        controller: _searchController,
        placeholder: 'Buscar no histórico...',
        prefix: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(FluentIcons.search),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildList(List<HistoryEntry> entries) {
    if (_isLoading) return const Center(child: ProgressRing());
    if (entries.isEmpty) {
      return const Center(child: Text('Nenhum item encontrado.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) => HistoryEntryTile(
        entry: entries[index],
        onDelete: () => _delete(entries[index]),
      ),
    );
  }
}
