import 'dart:convert';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class ItemUpdateApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;
  String itemId;
  Map<String, dynamic> data;

  ItemUpdateApi(
    this.apiUrl,
    this.token,
    this.safeId,
    this.itemId,
    this.data,
  ) : super(ContentType.applicationJson);

  Future<http.Response?> execute() async {
    try {
      this.setAuthTokenHeader(token);
      var response = await _putWithRedirect(
        Uri.parse("$apiUrl/v1/safe/$safeId/item/$itemId"),
        headers: headers,
        body: jsonEncode(data)
      );
      print("$apiUrl/v1/safe/$safeId");
      print(response.statusCode);
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> _putWithRedirect(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var response = await http.put(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 307) {
      var redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await _putWithRedirect(Uri.parse(redirectUrl), headers: headers, body: body, encoding: encoding);
      }
    }
    return response;
  }
}