import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/view/auth/service_not_available_page.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class ContentType {
  static String xWwwFormUrlencoded = "application/x-www-form-urlencoded";
  static String applicationJson = "application/json";
  static String multipartFormData = "multipart/form-data";
}

abstract class BaseApi {
  late StringBuffer deviceName = StringBuffer();
  late Map<String, String> headers = {};
  late String contentType;
  late IOClient httpClient;

  BuildContext? buildContext;

  late http.Response response_;

  BaseApi({
    required this.contentType,
    required this.buildContext
  }){
      HttpClient client = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      httpClient = IOClient(client);
  }

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

  Future<void> execute();

  http.Response get response {
    final db = AppDb();
    try{
      if (response_.statusCode == 401) {
        Navigator.pushReplacement(
          buildContext!,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );

        db.delete(db.modelUser).go();
        db.delete(db.modelSettings).go();

        // Finish deleting data from the database. and exception handling if the server is not available!!!

        return http.Response(response_.body, response_.statusCode);
      } else {
        return response_;
      }
    } catch (e){
      AppLogger.logger.w(e);

      db.select(db.modelUser).get().then((settings) {
        if (settings.length > 0) {
          Navigator.pushReplacement(
            buildContext!,
            MaterialPageRoute(builder: (context) => ServiceNotAvailablePage()),
          );
        } else {
          Navigator.pushReplacement(
            buildContext!,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
        }
      }).catchError((error) {
        AppLogger.logger.w("Error while getting settings: $error");

        Navigator.pushReplacement(
          buildContext!,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      });
    }

      return http.Response('', 500);
    }
}