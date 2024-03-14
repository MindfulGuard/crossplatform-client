import 'dart:async';

import 'package:mindfulguard/net/api/base.dart';

class UserInfoApi extends BaseApi {
  String apiUrl;
  String token;

  UserInfoApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      setAuthTokenHeader(token);

      print("$apiUrl/v1/user");
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/user"),
        headers: headers,
      ).timeout(const Duration(seconds: 7), onTimeout: () {
        throw TimeoutException('The connection timed out');
      });
      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}