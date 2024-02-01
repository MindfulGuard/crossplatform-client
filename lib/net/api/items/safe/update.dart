import 'dart:convert';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SafeUpdateApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;
  String name;
  String description;

  SafeUpdateApi(
    this.apiUrl,
    this.token,
    this.safeId,
    this.name,
    this.description,
  ) : super(ContentType.xWwwFormUrlencoded);

  Future<http.Response?> execute() async {
    try {
      Map<String, String> body = <String, String>{};
      body['name'] = name;
      body['description'] = description;

      this.setAuthTokenHeader(token);
      var response = await _postWithRedirect(Uri.parse("$apiUrl/v1/safe/$safeId"), headers: headers, body: body);
      print("$apiUrl/v1/safe/$safeId");
      print(response.statusCode);
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> _postWithRedirect(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var response = await http.put(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 307) {
      var redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await _postWithRedirect(Uri.parse(redirectUrl), headers: headers, body: body, encoding: encoding);
      }
    }
    return response;
  }
}