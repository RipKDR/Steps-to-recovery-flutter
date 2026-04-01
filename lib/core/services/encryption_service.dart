import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'logger_service.dart';

/// Encryption service for sensitive data
/// Uses AES-256-CBC encryption for data at rest
/// 
/// Security features:
/// - AES-256-CBC encryption with fresh IV per operation
/// - Keys stored in flutter_secure_storage (Keychain/Keystore)
/// - IV is generated per-encryption and stored with ciphertext
/// - Fails hard if secure storage is unavailable (no silent fallback)
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyTag = 'encryption_key';

  Key? _key;
  bool _initialized = false;
  bool _secureStorageAvailable = false;

  /// Initialize encryption service
  /// Generates or retrieves encryption key from secure storage
  /// Throws if secure storage is unavailable (critical for security)
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      var keyString = await _secureStorage.read(key: _keyTag);

      if (keyString == null) {
        // Generate new key
        _key = Key.fromSecureRandom(32);

        // Store in secure storage
        await _secureStorage.write(
          key: _keyTag,
          value: base64Encode(_key!.bytes),
        );
      } else {
        // Use existing key
        _key = Key(base64Decode(keyString));
      }

      _secureStorageAvailable = true;
      _initialized = true;
      LoggerService().debug('Encryption service initialized with secure storage');
    } catch (e, stackTrace) {
      LoggerService().error(
        'Secure storage unavailable - encryption disabled',
        error: e,
        stackTrace: stackTrace,
      );
      _key = null;
      _secureStorageAvailable = false;
      _initialized = false;
      throw StateError(
        'Secure storage is unavailable. EncryptionService cannot initialize '
        'without secure storage.',
      );
    }
  }

  /// Encrypt a string value
  /// Generates a fresh IV for each encryption operation
  /// Returns format: iv_base64:encrypted_base64
  String encrypt(String plainText) {
    _ensureInitialized();
    if (plainText.isEmpty) {
      return '';
    }

    // Generate fresh IV for this encryption operation
    final iv = IV.fromSecureRandom(16);
    
    try {
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Store IV with ciphertext (IV doesn't need to be secret, just unique)
      // Format: iv_base64:encrypted_base64
      return '${base64Encode(iv.bytes)}:${encrypted.base64}';
    } catch (e, stackTrace) {
      LoggerService().error(
        'Encryption failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Decrypt a string value
  /// Expects format: iv_base64:encrypted_base64
  String decrypt(String encryptedText) {
    _ensureInitialized();
    if (encryptedText.isEmpty) {
      return '';
    }

    try {
      // Parse IV and ciphertext from format: iv_base64:encrypted_base64
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw const FormatException('Invalid encrypted text format');
      }
      
      final iv = IV(base64Decode(parts[0]));
      final ciphertext = parts[1];
      
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      return encrypter.decrypt64(ciphertext, iv: iv);
    } catch (e) {
      // Fallback: try base64 decode for legacy data (unencrypted or fallback mode)
      try {
        return utf8.decode(base64Decode(encryptedText));
      } catch (_) {
        // Return as-is if all fails (might be plain text)
        LoggerService().debug('Decryption failed, returning as-is: ${e.toString()}');
        return encryptedText;
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

  /// Derive a key from a password/passphrase using PBKDF2
  Future<Key> deriveKeyFromPassword(
    String password, {
    String salt = 'steps_recovery_salt_v2',
    int iterations = 100000,
  }) async {
    // Use PBKDF2 with SHA-256 for proper key derivation
    final keyBytes = await computePBKDF2(password, salt, iterations, 32);
    return Key(Uint8List.fromList(keyBytes));
  }

  /// PBKDF2 key derivation using pure Dart implementation
  Future<List<int>> computePBKDF2(
    String password,
    String salt,
    int iterations,
    int keyLength,
  ) async {
    // Simple PBKDF2-HMAC-SHA256 implementation
    // For production, consider using package:pointycastle
    final saltBytes = utf8.encode(salt);
    final passwordBytes = utf8.encode(password);
    
    var dk = <int>[];
    var blockIndex = 1;
    
    while (dk.length < keyLength) {
      var u = hmacSha256(passwordBytes, [...saltBytes, ..._intToBytes(blockIndex)]);
      var t = List<int>.from(u);
      
      for (var i = 2; i <= iterations; i++) {
        u = hmacSha256(passwordBytes, u);
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      
      dk.addAll(t);
      blockIndex++;
    }
    
    return dk.take(keyLength).toList();
  }

  /// HMAC-SHA256 implementation
  List<int> hmacSha256(List<int> key, List<int> message) {
    final hmac = Hmac(crypto.sha256, key);
    return hmac.convert(message).bytes;
  }

  /// Convert int to 4-byte array (big-endian)
  List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  /// Clear encryption keys (for logout)
  Future<void> clearKeys() async {
    _key = null;
    _initialized = false;
    // Don't delete from secure storage - keep for next login
  }

  /// Check if encryption is initialized with secure storage
  bool get isInitialized => _initialized;
  
  /// Check if secure storage is available
  bool get isSecureStorageAvailable => _secureStorageAvailable;

  /// Compatibility shim for older callers and tests.
  @Deprecated('Always null. Retained for compatibility only.')
  Future<Null> get initializationError async => null;

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'EncryptionService not initialized. Call initialize() first.',
      );
    }
    if (_key == null) {
      throw StateError(
        'Encryption key not available. Secure storage may be unavailable.',
      );
    }
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await clearKeys();
  }

  void resetForTest() {
    _key = null;
    _initialized = false;
    _secureStorageAvailable = false;
  }
}
