import 'dart:async';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class UserAuditGetApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  int page;

  UserAuditGetApi(
    this.apiUrl,
    this.token,
    this.page
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      var response = await httpClient.get(
        Uri.parse("$apiUrl/v1/user/audit?page=$page"),
        headers: headers,
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}