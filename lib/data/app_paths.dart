import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Pasta onde ficam os dados locais do app (banco SQLite e chave de
/// criptografia): `<Documentos>/EloquenteText/data`. É criada na primeira
/// execução.
Future<Directory> appDataDirectory() async {
  final documents = await getApplicationDocumentsDirectory();
  final directory = Directory(p.join(documents.path, 'EloquenteText', 'data'));
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}
