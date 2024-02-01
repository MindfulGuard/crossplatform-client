import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:mindfulguard/view/main/items/safe_page.dart';
import 'package:mindfulguard/view/user/information.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String apiUrl = "";
  String accessToken = "";
  String password = "";
  String privateKey = "";
  int _currentIndex = 0;
  bool _isLoading = true;
  late Map<String, Object> userInfoApi = <String, Object>{}; // Declare userInfoApi as late
  late List<Widget> _pages; // Declare _pages as late
  Map<String, dynamic> itemsApiResponse = {};
  bool isLoading = true;

  Future<void> _initializeUserInfo() async {
    var userInfoResponse = await _checkUserAuthentication();
    if (userInfoResponse!.statusCode == 200) {
      var decodedInfo = json.decode(userInfoResponse.body);
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          userInfoApi = Map<String, Object>.from(decodedInfo);
          _isLoading = false;
          _initializePages(); 
        });
      }
    }
  }

  Future<void> _getItems() async {
    var api = await ItemsApi(apiUrl, accessToken).execute();

    if (api?.statusCode != 200 || api?.body == null) {
      return;
    } else {
      var decodedApiResponse = json.decode(api!.body);
      var decryptedApiResponse = await Crypto.crypto().decryptMapValues(
        decodedApiResponse,
        password,
        Crypto.fromPrivateKeyToBytes(privateKey)
      );
      
      setState(() {
        itemsApiResponse = decryptedApiResponse;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }


  Future<Response?> _checkUserAuthentication() async {
    var db = AppDb();
    List<ModelUserData> dataUser = await db.select(db.modelUser).get();
    ModelSetting? dataSettings = await (db.select(db.modelSettings)..where((t) => t.key.equals('api_url'))).getSingleOrNull();
    String? token = dataUser.firstOrNull?.accessToken;

    if (token == null || dataSettings == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } else{
      var userInfoApiResponse = await UserInfoApi(dataSettings.value!, token).execute();
      if (userInfoApiResponse?.statusCode != 200){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      }
      else{
        print(dataSettings.value);
        this.apiUrl = dataSettings.value!;
        this.password = dataUser.firstOrNull!.password!;
        this.privateKey = dataUser.firstOrNull!.privateKey!;
        this.accessToken = token;
        await _getItems();
        return userInfoApiResponse;
      }
    }
    return null;
  }

  void _initializePages() {
    _pages = [
      SafePage(
        itemsApiResponse: itemsApiResponse,
        apiUrl: apiUrl,
        token: accessToken,
        password: password,
        privateKey: privateKey,
        privateKeyBytes: Crypto.fromPrivateKeyToBytes(privateKey),
      ),
      UserInfoPage(
        apiUrl: apiUrl,
        userInfoApi: userInfoApi,
        token: accessToken,
      ),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _initializeUserInfo(); // Call _initializeUserInfo when tab is tapped
      _getItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('MindfulGuard'),
        ),
        body: _buildPageContent(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.source),
              label: "Data",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: "Profile",
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPageContent() {
    return _pages[_currentIndex];
  }
}