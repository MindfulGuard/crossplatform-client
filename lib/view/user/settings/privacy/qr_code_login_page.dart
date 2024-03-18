import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/view/components/qr.dart';
import 'package:mindfulguard/view/components/video_player.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeLoginPrivacySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  QrCodeLoginPrivacySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _QrCodeLoginPrivacySettingsPageState createState() => _QrCodeLoginPrivacySettingsPageState();
}

class _QrCodeLoginPrivacySettingsPageState extends State<QrCodeLoginPrivacySettingsPage>{

  /// Data is presented in JSON format {"apiServer": "", "userName": "", "password": "", "privateKey": ""}
  String data = '{}';
  bool isVisible = false;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async{
    var api = UserInfoApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();
    if (api.response.statusCode != 200){
      return;
    }
    
    final db = AppDb();
    var dataUser = await db.select(db.modelUser).getSingle();
    var dataSettings = await (db.select(db.modelSettings)..where((tbl) => tbl.key.equals('api_url'))).getSingle();
    Map<String, String> jsonData = {};
    
    jsonData['apiServer'] = dataSettings.value!;
    jsonData['userName'] = dataUser.login!;
    jsonData['password'] = dataUser.password!;
    jsonData['privateKey'] = dataUser.privateKey!;

    data = json.encode(jsonData);

    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.qrCodeLogin),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QrCodeLoginPrivacySettingsHelpPage()),
              );
            },
            icon: Icon(Icons.help_outline),
          ),
          ],
      ),
      body: Center(
        child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isVisible = !isVisible; // Switching data visibility
                  });
                },
                child: Qr(
                    isLoaded: isLoaded,
                    data: data,
                    isVisible: isVisible,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.qrCodeViewVisibleWarning,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

class Qr extends StatelessWidget{
  bool isLoaded;
  bool isVisible;
  String data;
  final double _size = 270;
  final QrEyeStyle _eyeStyle = const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.black);
  final QrDataModuleStyle _dataModuleStyle = const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.black);

  Qr({
    required this.isLoaded,
    this.isVisible = false,
    required this.data,
    Key? key,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return isVisible ?
      QrGenerator(
        data: data,
        size: _size,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        eyeStyle: _eyeStyle,
        dataModuleStyle: _dataModuleStyle
      ) :
      Stack(
        children: [
          IgnorePointer(
            ignoring: isLoaded ? false : true,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
              child: QrGenerator(
                data: 'Hello',
                size: _size,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                eyeStyle: _eyeStyle,
                dataModuleStyle: _dataModuleStyle,
              ),
          ),
          ),
          isLoaded 
          ? SizedBox()
          : Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      );
  }
}

class QrCodeLoginPrivacySettingsHelpPage extends StatefulWidget {
  QrCodeLoginPrivacySettingsHelpPage({Key? key}) : super(key: key);

  @override
  _QrCodeLoginPrivacySettingsHelpPageState createState() =>
      _QrCodeLoginPrivacySettingsHelpPageState();
}

class _QrCodeLoginPrivacySettingsHelpPageState
    extends State<QrCodeLoginPrivacySettingsHelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpReference),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IgnorePointer(
                ignoring: true,
                child: AppPlayer(
                  source: 'assets/video/sign_in_qr.webm',
                  mediaType: AppPlayerResourceType.asset,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.thisFeatureIsSupportedOnDevices('Android'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}