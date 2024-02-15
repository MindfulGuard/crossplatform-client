import 'dart:convert';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SignInApi extends BaseApi<http.Response> {
  String apiUrl;
  String login;
  String secretString;
  int tokenExpiration;
  String totp;
  String codeType;

  SignInApi(
    this.apiUrl,
    this.login,
    this.secretString,
    this.tokenExpiration,
    this.totp,
    this.codeType,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['login'] = login;
      body['secret_string'] = secretString;
      body['expiration'] = tokenExpiration.toString();
      body['code'] = totp;

      var response = await httpClient.post(
        Uri.parse("$apiUrl/v1/auth/sign_in?type=$codeType"),
        headers: headers,
        body: body,
        encoding: utf8
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}