import 'dart:async';
import 'dart:io';

import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class UserInfoApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;

  UserInfoApi(
    this.apiUrl,
    this.token
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      setAuthTokenHeader(token);

      print("$apiUrl/v1/user");
      var response = await http.get(
        Uri.parse("$apiUrl/v1/user"),
        headers: headers,
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException('The connection timed out');
      });
      return response;
    } on TimeoutException catch (e) {
      print(e);
      return null;
    } on SocketException catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}