import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class AdminUsersCreateApi extends BaseApi {
  String apiUrl;
  String token;
  String login;
  String secretString;

  AdminUsersCreateApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.login,
    required this.secretString,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  Future<void> execute() async {
    try {
      await init();

      this.setAuthTokenHeader(token);

      Map<String, String> body = {
        "login": login,
        "secret_string": secretString
      };

      response_ = await _postWithRedirect(
        Uri.parse("$apiUrl/v1/admin/users"),
        headers: headers,
        body: body,
        encoding: utf8,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }

  Future<http.Response> _postWithRedirect(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var response = await httpClient.post(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 307) {
      var redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await _postWithRedirect(Uri.parse(redirectUrl), headers: headers, body: body, encoding: encoding);
      }
    }
    return response;
  }
}