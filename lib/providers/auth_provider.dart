import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider {
  final storage = FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<String?> getCurrentUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<String?> getCurrentUserName() async {
    return await storage.read(key: 'user_name');
  }

  Future<void> storeUserDetails(
      String token, String userId, String userName) async {
    await storage.write(key: 'auth_token', value: token);
    await storage.write(key: 'user_id', value: userId);
    await storage.write(key: 'user_name', value: userName);
  }

  Future<void> register() async {
    await storage.write(key: 'is_registered', value: 'true');
  }

  Future<void> clearUserDetails() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'user_name');
  }

  Future<void> deregister() async {
    await storage.delete(key: 'is_registered');
  }
}
