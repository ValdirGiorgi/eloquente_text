import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_paths.dart';
import 'migrations.dart';

/// Banco SQLite local do app (histórico, estatísticas e configurações).
///
/// Usa `sqflite_common_ffi` no lugar do `sqflite` padrão porque o app roda
/// em desktop (Windows/Linux), não em Android/iOS.
///
/// Em produção use [AppDatabase.instance]; nos testes,
/// [AppDatabase.inMemory], que cria um banco descartável e não toca em
/// nenhum arquivo do usuário.
class AppDatabase {
  AppDatabase._({required this.fileName});

  static final AppDatabase instance = AppDatabase._(
    fileName: 'eloquente_text.db',
  );

  factory AppDatabase.inMemory() =>
      AppDatabase._(fileName: inMemoryDatabasePath);

  final String fileName;

  Database? _database;

  bool get _isInMemory => fileName == inMemoryDatabasePath;

  Future<Database> get database async {
    _initializeFfi();
    return _database ??= await openDatabase(
      _isInMemory
          ? fileName
          : p.join((await appDataDirectory()).path, fileName),
      version: schemaVersion,
      onCreate: (db, _) => createSchema(db),
      onUpgrade: upgradeSchema,
    );
  }

  /// O `sqflite` padrão espera Android/iOS: esta troca de fábrica registra a
  /// implementação FFI usada no desktop. Roda uma vez por processo.
  static bool _ffiInitialized = false;

  static void _initializeFfi() {
    if (_ffiInitialized) return;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _ffiInitialized = true;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
