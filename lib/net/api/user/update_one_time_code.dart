import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class UpdateOneTimeCodeApi extends BaseApi {
  String apiUrl;
  String token;
  String secretString;
  String type;

  UpdateOneTimeCodeApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.secretString,
    required this.type,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['secret_string'] = secretString;

      this.setAuthTokenHeader(token);

      response_ = await httpClient.put(
        Uri.parse("$apiUrl/v1/user/settings/auth/one_time_code?type=$type"),
        headers: headers,
        body: body,
        encoding: utf8,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}