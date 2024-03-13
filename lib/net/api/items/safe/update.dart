import 'dart:convert';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SafeUpdateApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  String name;
  String description;

  SafeUpdateApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.name,
    required this.description,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  Future<void> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['name'] = name;
      body['description'] = description;

      this.setAuthTokenHeader(token);
      response_ = await _postWithRedirect(Uri.parse("$apiUrl/v1/safe/$safeId"), headers: headers, body: body);
      print("$apiUrl/v1/safe/$safeId");
      print(response.statusCode);
      return;
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<http.Response> _postWithRedirect(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var response = await httpClient.put(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 307) {
      var redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await _postWithRedirect(Uri.parse(redirectUrl), headers: headers, body: body, encoding: encoding);
      }
    }
    return response;
  }
}