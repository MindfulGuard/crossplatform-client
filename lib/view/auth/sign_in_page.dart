import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/auth/sign_in.dart';
import 'package:mindfulguard/view/auth/sign_up_page.dart';
import 'package:mindfulguard/view/components/buttons.dart';
import 'package:mindfulguard/view/components/glass_morphism.dart';
import 'package:mindfulguard/view/components/text_filelds.dart';
import 'package:mindfulguard/view/main/main_page.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController apiUrl = TextEditingController();
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController privateKey = TextEditingController();
  TextEditingController oneTimeOrBackupCode = TextEditingController();
  String? _selectedOption = "basic";

  MobileScannerController cameraController = MobileScannerController();

  bool _onHoverTextSignUp = false;

  void _decodeData(String? jsonString) async{
    Map<String, dynamic> data = json.decode(jsonString!);
    if (data.isEmpty){
      return;
    } else{
      setState(() {
        apiUrl.text = data['apiServer']!;
        login.text = data['userName']!;
        password.text = data['password']!;
        privateKey.text = data['privateKey']!;
      });
    }
    cameraController.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    apiUrl.dispose();
    login.dispose();
    password.dispose();
    privateKey.dispose();
    _onHoverTextSignUp = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signIn),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AlignTextField(
                  labelText: AppLocalizations.of(context)!.apiServer,
                  controller: apiUrl,
                ),
                SizedBox(height: 10),
                AlignTextField(
                  labelText: AppLocalizations.of(context)!.loginUser,
                  controller: login,
                ),
                SizedBox(height: 10),
                AlignTextField(
                  labelText: AppLocalizations.of(context)!.password,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: password,
                ),
                SizedBox(height: 10),
                AlignTextField(
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  labelText: AppLocalizations.of(context)!.privateKey,
                  controller: privateKey,
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AlignTextField(
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 6,
                        labelText: AppLocalizations.of(context)!.oneTimeCode,
                        controller: oneTimeOrBackupCode,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedOption,
                      items: [
                        DropdownMenuItem(
                          value: 'basic',
                          child: Text("TOTP"),
                        ),
                        DropdownMenuItem(
                          value: 'backup',
                          child: Text(AppLocalizations.of(context)!.backupCode2FA),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value ?? 'basic';
                        });
                        AppLogger.logger.i("Selected one-time code type: $_selectedOption");
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () async {
                    final signInApi = await _signInApi();
                    if (signInApi == null || signInApi.statusCode != 200) {
                      if (signInApi!.statusCode == 400){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.incorrectData),
                          ),
                        );
                      } else if(signInApi.statusCode == 404){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.noSuchUserExists),
                          ),
                        );
                      } else if(signInApi.statusCode == 500 || signInApi.statusCode == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.failedToLogInToAccount),
                          ),
                        );
                      }
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.next),
                ),
                if (Platform.isAndroid)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.qr_code_scanner),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: SingleChildScrollView(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                                      child: GlassMorphism(
                                        start: 0.1,
                                        end: 0.2,
                                        child: Container(
                                          width: 400,
                                          constraints: BoxConstraints(maxHeight: 250),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: SingleChildScrollView(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minHeight: 100
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                        width: 225, // Camera width
                                                        height: 225, // Camera height
                                                        child: MobileScanner(
                                                          controller: cameraController,
                                                          onDetect: (capture) {
                                                            final List<Barcode> barcodes = capture.barcodes;
                                                            for (final barcode in barcodes) {
                                                              _decodeData(barcode.rawValue);
                                                            }
                                                          },
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Text(AppLocalizations.of(context)!.scanQrCodeSignIn),
                    ],
                  ),
                SizedBox(height: 20,),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      AppLogger.logger.d("Redirect to sign up page ...");

                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: MouseRegion(
                      onHover: (event){
                        setState(() {
                          _onHoverTextSignUp = true;
                        });
                      },
                      onExit: (event){
                        setState(() {
                          _onHoverTextSignUp = false;
                        });
                      },
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          decoration: _onHoverTextSignUp ? TextDecoration.underline : TextDecoration.none,
                          decorationColor: Colors.blue[800],
                        ),
                      ),
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Response?> _signInApi() async {

    String secretString = Crypto.hash().sha(utf8.encode(login.text+password.text+privateKey.text)).toString();
    var signInApi = SignInApi(
      apiUrl: apiUrl.text,
      login: login.text,
      secretString: secretString,
      tokenExpiration: 43200, // 30 days (in minutes)
      totp: oneTimeOrBackupCode.text,
      codeType: _selectedOption!
    );

    await signInApi.execute();

    if (signInApi.response.statusCode != 200){
      return signInApi.response;
    }

    String token = json.decode(signInApi.response.body)['token'];

    final modelUser = ModelUserCompanion(
      login: drift.Value(login.text),
      password: drift.Value(password.text),
      privateKey: drift.Value(privateKey.text),
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
    return signInApi.response;
  }
}