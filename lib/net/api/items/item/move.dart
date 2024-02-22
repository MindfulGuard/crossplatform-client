import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class ItemMoveToNewSafeApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String oldSafeId;
  String newSafeId;
  String itemId;

  ItemMoveToNewSafeApi(
    this.apiUrl,
    this.token,
    this.oldSafeId,
    this.newSafeId,
    this.itemId,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      var response = await httpClient.put(
        Uri.parse("$apiUrl/v1/safe/$oldSafeId/$newSafeId/item/$itemId"),
        headers: headers
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}