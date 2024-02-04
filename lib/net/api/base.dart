import 'dart:io';

class ContentType {
  static String xWwwFormUrlencoded = "application/x-www-form-urlencoded";
  static String applicationJson = "application/json";
}

abstract class BaseApi<T> {
  late StringBuffer deviceName;
  late Map<String, String> headers;
  late String contentType;

  BaseApi(this.contentType) {
    deviceName = StringBuffer();
    headers = <String, String>{};
    deviceName.write("MindfulGuard 0.0.1/");
    if (Platform.isAndroid) {
      deviceName.write('Android');
    } else if (Platform.isIOS) {
      deviceName.write('iOS');
    } else if (Platform.isMacOS) {
      deviceName.write('macOS');
    } else if (Platform.isWindows) {
      deviceName.write('Windows');
    } else if (Platform.isLinux) {
      deviceName.write('Linux');
    } else {
      deviceName.write('Unknown');
    }

    headers['Content-Type'] = contentType;
    headers['Device'] = deviceName.toString();
  }

  void setAuthTokenHeader(String token){
    headers['Authorization'] = "Bearer $token";
  }

  Future<T?> execute();
}