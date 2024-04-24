import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SignInApi extends BaseApi {
  String apiUrl;
  String login;
  String secretString;
  int tokenExpiration;
  String totp;
  String codeType;

  SignInApi({
    required this.apiUrl,
    required this.login,
    required this.secretString,
    required this.tokenExpiration,
    required this.totp,
    required this.codeType,
  }) : super(
    buildContext: null,
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  http.Response get response{
    return response_;
  }

  @override
  Future<void> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['login'] = login;
      body['secret_string'] = secretString;
      body['expiration'] = tokenExpiration.toString();
      body['code'] = totp;

      response_ = await httpClient.post(
        Uri.parse("$apiUrl/v1/auth/sign_in?type=$codeType"),
        headers: headers,
        body: body,
        encoding: utf8
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}