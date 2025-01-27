import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageProvider {
  static const offlineModeKey = 'offline_mode';
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> setOfflineMode(bool isOffline) async {
    await storage.write(key: offlineModeKey, value: isOffline.toString());
  }

  Future<bool> getOfflineMode() async {
    final value = await storage.read(key: offlineModeKey);
    return value == 'true';
  }
}