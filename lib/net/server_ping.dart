import 'package:http/http.dart' as http;

Future<bool> pingServer(String url) async {
  try {
    var response = await http.get(Uri.parse(url));
    return response.statusCode == 200;
  }
  catch (e){
    print(e);
    return false;
  }
}