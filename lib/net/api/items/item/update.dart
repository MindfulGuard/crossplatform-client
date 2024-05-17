import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class ItemUpdateApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  String itemId;
  Map<String, dynamic> data;

  ItemUpdateApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.itemId,
    required this.data,
  }) : super(
    contentType: ContentType.applicationJson
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await _putWithRedirect(
        Uri.parse("$apiUrl/v1/safe/$safeId/item/$itemId"),
        headers: headers,
        body: jsonEncode(data)
      );
      AppLogger.logger.d(response.statusCode);
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