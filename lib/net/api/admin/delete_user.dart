import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class AdminUsersDeleteApi extends BaseApi {
  String apiUrl;
  String token;
  String userId;

  AdminUsersDeleteApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.userId
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  Future<void> execute() async {
    try {
      await init();

      this.setAuthTokenHeader(token);

      response_ = await _deleteWithRedirect(
        Uri.parse("$apiUrl/v1/admin/users?id=$userId"),
        headers: headers,
        encoding: utf8,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }

  Future<http.Response> _deleteWithRedirect(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var response = await httpClient.delete(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 307) {
      var redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await _deleteWithRedirect(Uri.parse(redirectUrl), headers: headers, body: body, encoding: encoding);
      }
    }
    return response;
  }
}