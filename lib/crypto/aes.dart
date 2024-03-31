import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';

class CryptoHelper {
  final int keyLength = 32; // 256 bits
  final int ivLength = 16; // 128 bits
  final int iterations = 10000;

  Future<Map<String, Uint8List>> generateKeyAndIV(String password, Uint8List salt) async {
    SecretKey keyData = await deriveKey(password, salt);
    Uint8List keyBytes = Uint8List.fromList(await keyData.extractBytes());
    Uint8List iv = randomBytes(ivLength);
    return {'key': keyBytes, 'iv': iv};
  }
  
  Future<String> encrypt(String text, String password, Uint8List salt) async {
    if (text.isEmpty){
      return text;
    }

    final keyAndIV = await generateKeyAndIV(password, salt);

    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encrypt(
      utf8.encode(text),
      secretKey: SecretKey(keyAndIV['key']!),
      nonce: keyAndIV['iv'],
    );

    final List<int> result = keyAndIV['iv']! + secretBox.cipherText + secretBox.mac.bytes;

    return hex.encode(result);
  }

  Future<String?> decrypt(String ciphertext, String password, Uint8List salt) async {    
    final List<int> cText = hex.decode(ciphertext);
    final List<int> iv = cText.sublist(0, ivLength);
    final List<int> mac = cText.sublist(cText.length - 16);
    final List<int> text = cText.sublist(ivLength, cText.length - 16);

    final algorithm = AesGcm.with256bits();
    final Map<String, Uint8List> keyAndIV = await generateKeyAndIV(password, salt);

    try {
      final cleartext = await algorithm.decrypt(
        SecretBox(text, nonce: iv, mac: Mac(mac)),
        secretKey: SecretKey(keyAndIV['key']!),
      );
      return utf8.decode(cleartext);
    } catch (error) {
      print('Decryption failed: $error');
      return null;
    }
  }

  Future<SecretKey> deriveKey(String password, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: keyLength * 8,
    );

    return await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  Uint8List randomBytes(int length) {
    final buffer = Uint8List(length);
    final range = Random.secure();
    for (var i = 0; i < length; i++) {
      buffer[i] = range.nextInt(256);
    }
    return buffer;
  }

  Future<Map<String, dynamic>> decryptMapValues(
    Map<String, dynamic> originalMap,
    List<String> keys,
    String password,
    Uint8List privateKey,
  ) async {
    Map<String, dynamic> decryptedMap = {};
    for (var entry in originalMap.entries) {
      if (entry.value is String && (keys.contains(entry.key))) {
        // Add decryption logic based on your requirements here
        decryptedMap[entry.key] = await decrypt(entry.value, password, privateKey);
      } else if (entry.value is Map<String, dynamic>) {
        try {
          decryptedMap[entry.key] = await decryptMapValues(entry.value, keys, password, privateKey); // Recursively decrypt nested maps
        } catch (e) {
          decryptedMap[entry.key] = ''; // Set default value for failed decryption
        }
      } else if (entry.value is List<dynamic>) {
        List<dynamic> decryptedList = [];
        for (var listItem in entry.value) {
          if (listItem is Map<String, dynamic>) {
            try {
              decryptedList.add(await decryptMapValues(listItem, keys, password, privateKey)); // Recursively decrypt elements within lists
            } catch (e) {
              decryptedList.add(listItem); // Set default value for failed decryption
            }
          } else {
            try{
              decryptedList.add(listItem);
            } catch(e){
              decryptedList.add(listItem);
            }
          }
        }
        decryptedMap[entry.key] = decryptedList;
      } else {
        decryptedMap[entry.key] = entry.value;
      }
    }
    return decryptedMap;
  }
}