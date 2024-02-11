import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class ContentType {
  static String xWwwFormUrlencoded = "application/x-www-form-urlencoded";
  static String applicationJson = "application/json";
  static String multipartFormData = "multipart/form-data";
}

abstract class BaseApi<T> {
  late StringBuffer deviceName = StringBuffer();
  late Map<String, String> headers = {};
  late String contentType;

  BaseApi(this.contentType);

  /// Initializes the API settings including device information and headers.
  /// Retrieves the application information (version, platform) and sets the device name accordingly.
  /// Sets the content type header based on the provided [contentType].
  /// Adds the 'Authorization' header with the provided [token] for authentication, if applicable.
  /// This method should be called before making any API requests.
  Future<void> init() async {
    var info = await _appInfo();
    deviceName.write("MindfulGuard ${info.version}/");
    if (Platform.isAndroid) {
      deviceName.write('Android');
    } else if (Platform.isIOS) {
      deviceName.write('iOS');
    } else if (Platform.isMacOS) {
      deviceName.write('MacOS');
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

  Future<PackageInfo> _appInfo() async{
    return await PackageInfo.fromPlatform();
  }

  void setAuthTokenHeader(String token){
    headers['Authorization'] = "Bearer $token";
  }

  Future<T?> execute();
}