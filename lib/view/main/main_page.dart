import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:mindfulguard/view/components/passcode_page.dart';
import 'package:mindfulguard/view/main/items_and_files/safe_page.dart';
import 'package:mindfulguard/view/user/information.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  bool? passcodeSuccess = false;

  MainPage({
    this.passcodeSuccess,
    Key? key
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String apiUrl = "";
  String accessToken = "";
  String password = "";
  String privateKey = "";
  int _currentIndex = 0;
  late Map<String, Object> userInfoApi = <String, Object>{};
  late List<Widget> _pages;
  Map<String, dynamic> itemsApiResponse = {};
  bool isLoading = true; // Move _isLoading to the top level
  bool passcodeExists = false;
  bool screenLockOpen = false;

  @override
  void initState() {
    super.initState();
    _passcodeExists(context);
    _initializeUserInfo();
  }

  void __signOut(BuildContext context) async{
    final db = AppDb();
    var resultUser = await (db.select(db.modelUser)).getSingleOrNull();
    var resultSettings = await (db.select(db.modelSettings)..where((tbl) => tbl.key.equals('api_url'))).getSingleOrNull();

    if (resultUser == null || resultSettings == null){
      return;
    }
    
    var tokenHash = Crypto.hash().sha(resultUser.accessToken!).toString().substring(0, 28); // Hashing the token and extracts the first 28 characters.

    String tokenIdResult = "";
  
    var userInfoApiResponse = UserInfoApi(
      buildContext: context,
      apiUrl: resultSettings.value!,
      token: resultUser.accessToken!,
    );

    await userInfoApiResponse.execute();

    var userInfoApiResponseJson = json.decode(userInfoApiResponse.response.body);

    for (var val in userInfoApiResponseJson['tokens']){
      if (val['short_hash'] == null){ // Checks if the "short_hash" key exists.
        return;
      } else{
        if (val['short_hash'] == tokenHash){ // Retrieves the token id if the token hash matches the one found.
          tokenIdResult = val['id'];
          break;
        }
      }
    }

    var api = SignOutApi(
      buildContext: context,
      apiUrl: resultSettings.value!,
      token: resultUser.accessToken!,
      tokenId:  tokenIdResult,
    );

    await api.execute();

    if (api.response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );

        final db = AppDb();
        await db.delete(db.modelUser).go();
        await db.delete(db.modelSettings).go();

    } else{
      return;
    }
  }

  Future<void> _passcodeExists(BuildContext context) async{
    final db = AppDb();
    var result = await (db.select(db.modelSettings)..where((tbl) => tbl.key.equals('passcode'))).getSingleOrNull();

    if (result == null){
      setState(() {
        widget.passcodeSuccess = true;
      });
      return;
    }

    setState(() {
      passcodeExists = true;
    });

    if (widget.passcodeSuccess == true){
      return;
    } else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InsertPasscodePage(
          appBar: AppBar(actions: [
            IconButton(
              onPressed: (){
                __signOut(context);
              },
              icon: Icon(
                color: Colors.red,
                Icons.logout
              )
            )
          ]),
          passcode: result.value!,
          passcodeSuccess: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage(
                passcodeSuccess: true,
              ))
            );
          }
        )),
      );
    }
  }

  Future<void> _initializeUserInfo() async {
    var userInfoResponse = await _checkUserAuthentication();
    await _getItems();

    if (userInfoResponse?.statusCode == 200) {
      var decodedInfo = json.decode(userInfoResponse!.body);
      if (mounted) {
        setState(() {
          userInfoApi = Map<String, Object>.from(decodedInfo);
          isLoading = false;
          _initializePages();
        });
      }
    }
  }

  Future<void> _getItems() async {
    var api = ItemsApi(
      buildContext: context,
      apiUrl: apiUrl,
      token: accessToken 
    );

    await api.execute();

    var decodedApiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));
    var decryptedApiResponse = await Crypto.crypto().decryptMapValues(
      decodedApiResponse,
      ['description'], // Decodes the description of the safe.
      password,
      Crypto.fromPrivateKeyToBytes(privateKey),
    );

    setState(() {
      itemsApiResponse = decryptedApiResponse;
    });
  }

  Future<Response?> _checkUserAuthentication() async {
    var db = AppDb();
    List<ModelUserData> dataUser = await db.select(db.modelUser).get();
    ModelSetting? dataSettings =
        await (db.select(db.modelSettings)..where((t) => t.key.equals('api_url')))
            .getSingleOrNull();
    String? token = dataUser.firstOrNull?.accessToken;

    if (token == null || dataSettings == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } else {
      var userInfoApiResponse = UserInfoApi(
        buildContext: context,
        apiUrl: dataSettings.value!,
        token: token,
      );

      await userInfoApiResponse.execute();

      print(dataSettings.value);
      this.apiUrl = dataSettings.value!;
      this.password = dataUser.firstOrNull!.password!;
      this.privateKey = dataUser.firstOrNull!.privateKey!;
      this.accessToken = token;
      return userInfoApiResponse.response;
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
        diskInfo: itemsApiResponse['disk'],
        token: accessToken,
      ),
    ];
  }

  Future<void> _lockScreen() async{
    var db = AppDb();
    var result = await (db.select(db.modelSettings)..where((tbl) => tbl.key.equals('passcode'))).getSingleOrNull();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InsertPasscodePage(
        appBar: AppBar(actions: [
          IconButton(
            onPressed: (){
              __signOut(context);
            },
            icon: Icon(
              color: Colors.red,
              Icons.logout
            )
          )
        ]),
        passcode: result!.value!,
        passcodeSuccess: (){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage(
              passcodeSuccess: true,
            ))
          );
        }
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MindfulGuard'),
        actions: passcodeExists ?
        [
          IconButton(
            onPressed: () async{
              setState(() {
                screenLockOpen = true;
              });
              Future.delayed(Duration(milliseconds: 465), () {
                _lockScreen();
              });
            },
            icon: screenLockOpen 
            ? Icon(
                Icons.lock_open_outlined
              ).animate().crossfade(
                delay: 256.ms,
                builder: ((context) => Icon(
                  Icons.lock_outline
                ))
              )
            : Icon(Icons.lock_open_outlined)
          )
        ]
        : null
      ),
      body: _buildPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: isLoading ? null : onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.source),
            label: AppLocalizations.of(context)!.data,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return _pages[_currentIndex];
    }
  }

  Future<void> onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;
      isLoading = true;
    });
    
    await _getItems();
    await _initializeUserInfo();

    setState(() {
      isLoading = false;
    });
  }
}
