import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/auth/sign_in.dart';
import 'package:mindfulguard/net/api/auth/sign_up.dart';
import 'package:mindfulguard/net/api/configuration.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/components/qr.dart';
import 'package:mindfulguard/view/components/text_filelds.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mindfulguard/view/main/main_page.dart';
import 'package:otp/otp.dart';
import 'package:uuid/uuid.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController apiUrl = TextEditingController();
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();
  
  String msg = "";
  String privateKey = "";

  bool isRegistered = false;
  String base32TotpCode = "";
  List<dynamic> backupCodes = []; // List<dynamic>

  Widget buildInfo = Container();

  @override
  void dispose(){
    super.dispose();
    apiUrl.dispose();
    login.dispose();
    password.dispose();  
  }

  void _buildSignUpInfo(){
    bool isDesktop = false;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS){
      isDesktop = true;
    }

    setState(() {
      buildInfo = Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Private Key:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(privateKey),
            SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  'TOTP Code:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isDesktop 
                ? IconButton(
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Center(
                          child: QrGenerator(
                            size: 256,
                            data: "otpauth://totp/${login.text}?secret=$base32TotpCode&issuer=MindfulGuard",
                          ),
                        );
                      }
                    );
                  },
                  icon: Icon(Icons.qr_code)
                )
                : Container()
              ],
            ),
            Text(base32TotpCode),
            SizedBox(height: 8.0),
            Text(
              'Backup Codes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: backupCodes
                  .map((code) => Text(code.toString()))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _signIn() async {
    var configApi = ConfigurationApi(
      apiUrl: apiUrl.text
    );
    await configApi.execute();

    if (configApi.response.statusCode != 200){
      return;
    }
    Map<String, dynamic> configResponse = json.decode(configApi.response.body);
    print(configApi.response.body);

    RegExp regExp = RegExp(configResponse['password_rule']);
    if (!regExp.hasMatch(password.text)){
      return;
    }

    String secretString = Crypto.hash().sha(utf8.encode(login.text+password.text+privateKey)).toString();

    var signInApi = SignInApi(
      apiUrl: apiUrl.text,
      login: login.text,
      secretString: secretString,
      tokenExpiration: 43200, // 30 days (in minutes)
      totp: OTP.generateTOTPCodeString(
        base32TotpCode, 
        DateTime.now().millisecondsSinceEpoch,
        interval: 30,
        length: 6,
        algorithm: Algorithm.SHA1,
        isGoogle: true
      ),
      codeType: 'basic'
    );

    await signInApi.execute();

    print(signInApi.response.statusCode);
    if (signInApi.response.statusCode != 200){
      return;
    }

    String token = json.decode(signInApi.response.body)['token'];

    final modelUser = ModelUserCompanion(
      login: drift.Value(login.text),
      password: drift.Value(password.text),
      privateKey: drift.Value(privateKey),
      accessToken: drift.Value(token)
    );

    final modelSettings = ModelSettingsCompanion(
      key: drift.Value('api_url'),
      value: drift.Value(apiUrl.text)
    );

    final db = AppDb();

    await db.delete(db.modelUser).go(); // Deletes all rows in the Users table, since there should only be one record.
    await db.into(db.modelUser)
      .insert(modelUser);

    await db.into(db.modelSettings)
      .insert(
        modelSettings,
        onConflict: drift.DoUpdate((_)=>modelSettings, target: [db.modelSettings.key]), 
      );
    
    RestartWidget.restartApp(context);
    return;
  }

  Future<void> _signUp() async {
    var configApi = ConfigurationApi(
      apiUrl: apiUrl.text
    );
    await configApi.execute();

    if (configApi.response.statusCode != 200){
      return;
    }
    Map<String, dynamic> configResponse = json.decode(configApi.response.body);
    print(configApi.response.body);

    RegExp regExp = RegExp(configResponse['password_rule']);
    if (!regExp.hasMatch(password.text)){
      return;
    }

    setState(() {
      privateKey = const Uuid().v4();
    });

    String secretString = Crypto.hash().sha(utf8.encode(login.text+password.text+privateKey)).toString();

    var signUpApi = SignUpApi(
      apiUrl: apiUrl.text,
      login: login.text,
      secretString: secretString
    );

    await signUpApi.execute();

    print(signUpApi.response.statusCode);

    setState(() {
      msg = json.decode(
        utf8.decode(signUpApi.response.body.runes.toList())
      )['msg'][AppLocalizations.of(context)?.localeName] ?? json.decode(signUpApi.response.body)['msg']['en'];
    });

    if (signUpApi.response.statusCode == 200){
      var body = json.decode(signUpApi.response.body);
      setState(() {
        base32TotpCode = body['secret_code'];
        backupCodes = body['backup_codes'];
        isRegistered = true;
      });
      _buildSignUpInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.signUp),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AlignTextField(
                  labelText: "Api url",
                  controller: apiUrl,
                ),
                SizedBox(height: 10),
                AlignTextField(
                  labelText: "Login",
                  controller: login,
                ),
                SizedBox(height: 10),
                AlignTextField(
                  labelText: "Password",
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: password,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () async{
                    isRegistered ? _signIn() : _signUp();
                  },
                  child: Text(
                    isRegistered 
                    ? AppLocalizations.of(context)!.next
                    : AppLocalizations.of(context)!.send
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: Colors.red
                    )
                  ),
                ),
                SizedBox(height: 20),
                buildInfo,
                SizedBox(height: 10),
                isRegistered
                ? ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: (){
                      return "Login: ${login.text}\nPassword: ${password.text}\nPrivate Key: $privateKey\n\nTOTP code: $base32TotpCode\n\nBackup Codes: $backupCodes";
                    }()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.valueCopiedToClipboard),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy),
                  label: Text(AppLocalizations.of(context)!.copy),
                )
                : Container()
              ]
          )
        )
      )
    );
  }
}