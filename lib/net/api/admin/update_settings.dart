import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class AdminSettingsUpdateApi extends BaseApi {
  String apiUrl;
  String token;
  String key;
  String value;

  AdminSettingsUpdateApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.key,
    required this.value,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['value'] = value;

      this.setAuthTokenHeader(token);
      response_ = await _putWithRedirect(Uri.parse("$apiUrl/v1/admin/settings?key=$key"), headers: headers, body: body);

      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }

  Future<http.Response> _putWithRedirect(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var response = await httpClient.put(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 307) {
      var redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await _putWithRedirect(Uri.parse(redirectUrl), headers: headers, body: body, encoding: encoding);
      }
    }
    return response;
  }
}