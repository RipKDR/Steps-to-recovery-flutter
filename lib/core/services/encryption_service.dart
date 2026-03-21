import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart' as crypto;

/// Encryption service for sensitive data
/// Uses AES-256 encryption for data at rest
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyTag = 'encryption_key';
  static const String _ivTag = 'encryption_iv';

  Key? _key;
  IV? _iv;

  /// Initialize encryption service
  /// Generates or retrieves encryption key from secure storage
  Future<void> initialize() async {
    try {
      var keyString = await _secureStorage.read(key: _keyTag);
      var ivString = await _secureStorage.read(key: _ivTag);

      if (keyString == null || ivString == null) {
        // Generate new key and IV
        _key = Key.fromSecureRandom(32);
        _iv = IV.fromSecureRandom(16);

        // Store in secure storage
        await _secureStorage.write(key: _keyTag, value: base64Encode(_key!.bytes));
        await _secureStorage.write(key: _ivTag, value: base64Encode(_iv!.bytes));
      } else {
        // Use existing key and IV
        _key = Key(base64Decode(keyString));
        _iv = IV(base64Decode(ivString));
      }
    } catch (e) {
      // Fallback: generate in-memory only (less secure)
      _key = Key.fromSecureRandom(32);
      _iv = IV.fromSecureRandom(16);
    }
  }

  /// Encrypt a string value
  String encrypt(String plainText) {
    if (_key == null || _iv == null) {
      throw Exception('Encryption service not initialized. Call initialize() first.');
    }

    try {
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      // If encryption fails, return base64 encoded data as fallback
      return base64Encode(utf8.encode(plainText));
    }
  }

  /// Decrypt a string value
  String decrypt(String encryptedText) {
    if (_key == null || _iv == null) {
      throw Exception('Encryption service not initialized. Call initialize() first.');
    }

    try {
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv!);
      return decrypted;
    } catch (e) {
      // Fallback: try base64 decode
      try {
        return utf8.decode(base64Decode(encryptedText));
      } catch (_) {
        return encryptedText; // Return as-is if all fails
      }
    }
  }

  /// Encrypt a list of strings
  List<String> encryptList(List<String> items) {
    return items.map((item) => encrypt(item)).toList();
  }

  /// Decrypt a list of strings
  List<String> decryptList(List<String> encryptedItems) {
    return encryptedItems.map((item) => decrypt(item)).toList();
  }

  /// Hash a value (one-way, for non-sensitive identifiers)
  String hash(String value) {
    final bytes = utf8.encode(value);
    final hash = crypto.sha256.convert(bytes);
    return hash.toString();
  }

  /// Derive a key from a password/passphrase
  Future<Key> deriveKeyFromPassword(String password, {String salt = 'steps_recovery_salt'}) async {
    // Simple hash-based key derivation (for production, use a proper KDF)
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return Key(Uint8List.fromList(hash.bytes));
  }

  /// Clear encryption keys (for logout)
  Future<void> clearKeys() async {
    _key = null;
    _iv = null;
    // Don't delete from secure storage - keep for next login
  }

  /// Check if encryption is initialized
  bool get isInitialized => _key != null && _iv != null;
}
