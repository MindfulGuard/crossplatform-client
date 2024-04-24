import 'dart:async';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class ItemsApi extends BaseApi {
  String apiUrl;
  String token;

  ItemsApi({
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
      this.setAuthTokenHeader(token);
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/safe/all/item"),
        headers: headers,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}