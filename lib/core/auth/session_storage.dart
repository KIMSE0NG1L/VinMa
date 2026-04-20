import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  SessionStorage._();

  static const _sessionTokenKey = 'vinma_session_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveSessionToken(String token) {
    return _storage.write(key: _sessionTokenKey, value: token);
  }

  static Future<String?> readSessionToken() {
    return _storage.read(key: _sessionTokenKey);
  }

  static Future<void> clearSessionToken() {
    return _storage.delete(key: _sessionTokenKey);
  }
}
