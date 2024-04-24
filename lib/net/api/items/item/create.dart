import 'dart:convert';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class ItemCreateApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  Map<String, dynamic> body;

  ItemCreateApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.body,
  }) : super(
    contentType: ContentType.applicationJson
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      
      response_ = await httpClient.post(
        Uri.parse("$apiUrl/v1/safe/$safeId/item"),
        headers: headers,
        body: jsonEncode(body),
        encoding: utf8,
      );

      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}