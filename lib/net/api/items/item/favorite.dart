import 'package:mindfulguard/net/api/base.dart';

class ItemFavoriteApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  String itemId;

  ItemFavoriteApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.itemId,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.put(
        Uri.parse("$apiUrl/v1/safe/$safeId/item/$itemId/favorite"),
        headers: headers
      );
      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}