import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class ItemFavoriteApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;
  String itemId;

  ItemFavoriteApi(
    this.apiUrl,
    this.token,
    this.safeId,
    this.itemId,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      var response = await httpClient.put(
        Uri.parse("$apiUrl/v1/safe/$safeId/item/$itemId/favorite"),
        headers: headers
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}