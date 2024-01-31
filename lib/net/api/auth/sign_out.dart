import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SignOutApi extends BaseApi<http.Response> {
  String apiUrl;
  String tokenId;
  String token;

  SignOutApi(
    this.apiUrl,
    this.tokenId,
    this.token,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      setAuthTokenHeader(token);
      var response = await http.delete(
        Uri.parse("$apiUrl/v1/auth/sign_out/$tokenId"),
        headers: headers,
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}