import 'dart:convert';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class UpdateSecretStringApi extends BaseApi {
  String apiUrl;
  String token;
  String oldSecretString;
  String newSecretString;
  String oneTimeCode;

  UpdateSecretStringApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.oldSecretString,
    required this.newSecretString,
    required this.oneTimeCode
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      Map<String, String> body = <String, String>{};
      body['old_secret_string'] = oldSecretString;
      body['new_secret_string'] = newSecretString;
      body['code'] = oneTimeCode;

      this.setAuthTokenHeader(token);

      response_ = await httpClient.put(
        Uri.parse("$apiUrl/v1/user/settings/auth/secret_string"),
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