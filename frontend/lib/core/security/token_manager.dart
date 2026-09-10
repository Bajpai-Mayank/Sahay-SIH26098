import 'secure_storage.dart';

/// Manages JWT access and refresh token lifecycle on the client.
class TokenManager {
  static const String _keyAccessToken = 'sahay_access_token';
  static const String _keyRefreshToken = 'sahay_refresh_token';

  final SecureStorageService _storage;
  String? _cachedAccessToken;

  TokenManager(this._storage);

  String? get cachedAccessToken => _cachedAccessToken;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _cachedAccessToken = accessToken;
    await _storage.write(_keyAccessToken, accessToken);
    await _storage.write(_keyRefreshToken, refreshToken);
  }

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(_keyAccessToken);
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(_keyRefreshToken);
  }

  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    await _storage.delete(_keyAccessToken);
    await _storage.delete(_keyRefreshToken);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
