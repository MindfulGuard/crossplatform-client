import 'dart:async';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class AdminUsersGetApi extends BaseApi {
  String apiUrl;
  String token;
  int page;

  AdminUsersGetApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.page
  }) : super(
    contentType: ContentType.applicationJson,
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/admin/users/all?page=$page&per_page=20"),
        headers: headers,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}

class AdminUsersSearchGetApi extends BaseApi {
  String apiUrl;
  String token;
  String value;
  String type;

  AdminUsersSearchGetApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.value,
    required this.type,
  }) : super(contentType: ContentType.xWwwFormUrlencoded);

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);

      AppLogger.logger.d(apiUrl);

      final uri = _parseUri(apiUrl, "/v1/admin/users/search", {"by": type});
      final request = http.Request("GET", uri);

      request.headers.addAll(headers);
      request.bodyFields = {
        "value": value,
      };

      final streamedResponse = await httpClient.send(request);
      response_ = await http.Response.fromStream(streamedResponse);

      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }

  Uri _parseUri(String apiUrl, String path, Map<String, String> queryParams) {
    final uri = Uri.parse(apiUrl);

    if (uri.hasScheme) {
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: path,
        queryParameters: queryParams,
      );
    } else {
      throw FormatException("Invalid URI: $apiUrl");
    }
  }
}