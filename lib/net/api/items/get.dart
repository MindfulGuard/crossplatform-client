import 'dart:async';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class ItemsApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;

  ItemsApi(
    this.apiUrl,
    this.token
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      this.setAuthTokenHeader(token);
      var response = await http.get(
        Uri.parse("$apiUrl/v1/safe/all/item"),
        headers: headers,
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}