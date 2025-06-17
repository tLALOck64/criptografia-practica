import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Genera una clave a partir de la contraseña del usuario
  encrypt.Key _generateKey(String password) {
    // Usar SHA-256 para generar una clave de 32 bytes a partir de la contraseña
    final List<int> passwordBytes = utf8.encode(password);
    final Digest digest = sha256.convert(passwordBytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  // Cifra un texto con la contraseña proporcionada
  String encryptData(String plainText, String password) {
    try {
      final key = _generateKey(password);
      final iv = encrypt.IV.fromLength(16); // Vector de inicialización
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Guardar IV y datos cifrados juntos
      final Map<String, String> encryptedData = {
        'iv': base64.encode(iv.bytes),
        'data': encrypted.base64
      };
      
      return jsonEncode(encryptedData);
    } catch (e) {
      return 'Error al cifrar: $e';
    }
  }

  // Descifra un texto con la contraseña proporcionada
  String decryptData(String encryptedText, String password) {
    try {
      final Map<String, dynamic> encryptedData = jsonDecode(encryptedText);
      final key = _generateKey(password);
      final iv = encrypt.IV.fromBase64(encryptedData['iv']);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      return encrypter.decrypt64(encryptedData['data'], iv: iv);
    } catch (e) {
      return 'Error al descifrar: $e';
    }
  }
} 