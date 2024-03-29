import 'dart:async';
import 'package:mindfulguard/net/api/base.dart';

class UserAuditGetApi extends BaseApi {
  String apiUrl;
  String token;
  int page;


  UserAuditGetApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.page
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/user/audit?page=$page"),
        headers: headers,
      );
      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}