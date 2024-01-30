import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class Hash {
  Digest sha(Object input, {int length = 256}) {
    if (length != 256 && length != 512) {
      throw ArgumentError('Unsupported hash length. Only 256 and 512 are supported.');
    }

    late Uint8List content;

    if (input is String) {
      content = utf8.encode(input);
    } else if (input is Uint8List) {
      content = input;
    } else {
      throw ArgumentError('Input must be either a String or Uint8List.');
    }

    if (length == 256) {
      var hash = sha256.convert(content);
      return hash;
    } else {
      var hash = sha512.convert(content);
      return hash;
    }
  }
}