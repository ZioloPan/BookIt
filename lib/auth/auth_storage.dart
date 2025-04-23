import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final _secureStorage = const FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await _secureStorage.write(key: 'jwt_token', value: token);
}

Future<String?> getStoredToken() async {
  return _secureStorage.read(key: 'jwt_token');
}

Future<void> deleteToken() async {
  await _secureStorage.delete(key: 'jwt_token');
}

bool isTokenExpired(String token) {
  return JwtDecoder.isExpired(token);
}
