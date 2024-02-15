import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'package:mindfulguard/net/api/base.dart';

class FileUploadApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;
  List<int> body;
  String fileName;

  FileUploadApi(
    this.apiUrl,
    this.token,
    this.safeId,
    this.body,
    this.fileName,
  ) : super(ContentType.multipartFormData);

  @override
  Future<http.Response?> execute() async {
    try {
      HttpClient client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      IOClient httpClient = IOClient(client);

      await init();
      this.setAuthTokenHeader(token);

      // Создаем объект MultipartRequest и добавляем в него файл
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$apiUrl/v1/safe/$safeId/content"),
      );
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'files',
        body,
        filename: fileName,
      ));

      var streamedResponse = await httpClient.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
