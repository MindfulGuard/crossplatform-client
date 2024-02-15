import 'dart:convert';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SafeCreateApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
    String name;
  String description;

  SafeCreateApi(
    this.apiUrl,
    this.token,
    this.name,
    this.description,
  ) : super(ContentType.xWwwFormUrlencoded);

  Future<http.Response?> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['name'] = name;
      body['description'] = description;

      this.setAuthTokenHeader(token);
      var response = await _postWithRedirect(Uri.parse("$apiUrl/v1/safe"), headers: headers, body: body);
      return response;
    } catch (e) {
      print(e);
      return null;
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