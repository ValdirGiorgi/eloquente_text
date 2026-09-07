import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as p;

import 'app_paths.dart';

/// Contrato de cifragem usado pelas configurações.
///
/// Existe para os testes trocarem a criptografia real por uma implementação
/// em memória — [EncryptionService] depende de arquivos no disco do usuário.
abstract interface class SecretCodec {
  String encryptValue(String plainText);

  String decryptValue(String encryptedValue);
}

/// Criptografa as API keys com AES-256 antes de gravá-las no banco local.
///
/// A chave de criptografia é gerada uma vez por instalação e guardada em
/// texto puro em `security.key`, ao lado do banco. Isso protege contra
/// alguém abrir o banco isoladamente (copiando só o arquivo `.db`), mas não
/// substitui um cofre de segredos do sistema operacional.
///
/// Cada valor cifrado carrega o próprio IV aleatório, no formato
/// `IV_EM_BASE64:CIFRADO_EM_BASE64`.
class EncryptionService implements SecretCodec {
  EncryptionService._();

  static final EncryptionService instance = EncryptionService._();

  static const String _keyFileName = 'security.key';
  static const int _keyLengthInBytes = 32; // AES-256

  encrypt.Encrypter? _encrypter;

  /// Carrega a chave da instalação, gerando-a na primeira execução.
  /// Precisa rodar antes de qualquer leitura ou gravação de API key.
  Future<void> init() async {
    final file = File(p.join((await appDataDirectory()).path, _keyFileName));

    final key = await file.exists()
        ? encrypt.Key.fromBase64(await file.readAsString())
        : await _createKey(file);

    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  Future<encrypt.Key> _createKey(File file) async {
    final key = encrypt.Key.fromSecureRandom(_keyLengthInBytes);
    await file.create(recursive: true);
    await file.writeAsString(key.base64);
    return key;
  }

  @override
  String encryptValue(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _requireEncrypter().encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  @override
  String decryptValue(String encryptedWithIv) {
    final parts = encryptedWithIv.split(':');
    if (parts.length != 2) {
      throw const FormatException('Valor criptografado em formato inválido.');
    }
    return _requireEncrypter().decrypt(
      encrypt.Encrypted.fromBase64(parts[1]),
      iv: encrypt.IV.fromBase64(parts[0]),
    );
  }

  encrypt.Encrypter _requireEncrypter() {
    final encrypter = _encrypter;
    if (encrypter == null) {
      throw StateError('EncryptionService.init() ainda não foi chamado.');
    }
    return encrypter;
  }
}
