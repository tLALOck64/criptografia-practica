import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Guardar un valor cifrado
  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Leer un valor cifrado
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Eliminar un valor cifrado
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // Eliminar todos los valores cifrados
  Future<void> deleteAllSecureData() async {
    await _storage.deleteAll();
  }

  // Verificar si existe una clave
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Obtener todas las claves almacenadas
  Future<Map<String, String>> getAllValues() async {
    return await _storage.readAll();
  }
} 