import 'dart:convert';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SignUpApi extends BaseApi {
  String apiUrl;
  String login;
  String secretString;

  SignUpApi({
    required this.apiUrl,
    required this.login,
    required this.secretString,
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

      response_ = await httpClient.post(
        Uri.parse("$apiUrl/v1/auth/sign_up"),
        headers: headers,
        body: body,
        encoding: utf8
      );
      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}