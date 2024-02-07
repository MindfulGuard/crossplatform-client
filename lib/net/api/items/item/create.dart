import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mindfulguard/net/api/base.dart';

class ItemCreateApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;
  Map<String, dynamic> body;

  ItemCreateApi(
    this.apiUrl,
    this.token,
    this.safeId,
    this.body,
  ) : super(ContentType.applicationJson);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      
      var response = await http.post(
        Uri.parse("$apiUrl/v1/safe/$safeId/item"),
        headers: headers,
        body: jsonEncode(body),
        encoding: utf8,
      );

      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}