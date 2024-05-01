import 'dart:async';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class AdminSettingsGetApi extends BaseApi {
  String apiUrl;
  String token;

  AdminSettingsGetApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token
  }) : super(
    contentType: ContentType.applicationJson,
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/admin/settings"),
        headers: headers,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}