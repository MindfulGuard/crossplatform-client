import 'dart:convert';
import 'dart:typed_data';

import 'package:mindfulguard/crypto/aes.dart';
import 'package:mindfulguard/crypto/hash.dart';

class Crypto{
  static Hash hash(){
    return Hash();
  }

  static CryptoHelper crypto(){
    return CryptoHelper();
  }

  static Uint8List fromPrivateKeyToBytes(String privateKey){
    List<int> bytes = utf8.encode(privateKey);
    return Uint8List.fromList(bytes);
  }
}