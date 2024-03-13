import 'package:mindfulguard/net/api/base.dart';

class SignOutApi extends BaseApi {
  String apiUrl;
  String tokenId;
  String token;

  SignOutApi({
    required super.buildContext,
    required this.apiUrl,
    required this.tokenId,
    required this.token,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      setAuthTokenHeader(token);
      response_ = await httpClient.delete(
        Uri.parse("$apiUrl/v1/auth/sign_out/$tokenId"),
        headers: headers,
      );
      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}