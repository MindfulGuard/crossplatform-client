import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/auth/sign_in.dart';
import 'package:mindfulguard/net/api/configuration.dart';
import 'package:mindfulguard/view/components/buttons.dart';
import 'package:mindfulguard/view/components/text_filelds.dart';
import 'package:mindfulguard/view/main/main_page.dart';


class SignInPage extends StatefulWidget {

  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String errorMessage = "";

  TextEditingController apiUrl = TextEditingController();
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController privateKey = TextEditingController();
  TextEditingController tokenExpiration = TextEditingController();
  TextEditingController oneTimeOrBackupCode = TextEditingController();
  String? _selectedOption = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Sign in';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
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
                SizedBox(height: 10),
                AlignTextField(
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  labelText: "Private key",
                  controller: privateKey,
                ),
                SizedBox(height: 10),
                AlignTextField(
                  keyboardType: TextInputType.number,
                  labelText: "Token expiration (max 90 days)",
                  controller: tokenExpiration,
                ),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AlignTextField(
                        labelText: "Totp",
                        controller: oneTimeOrBackupCode,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10), // Add a small space between elements
                    DropDown(
                      options: const ['basic', 'backup'],
                      onOptionChanged: (String? selectedValue) {
                        _selectedOption = selectedValue;
                        print(selectedValue);
                        // Perform other actions upon value change
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () async {
                    final signInApi = await _signInApi();
                    if (signInApi == null || signInApi?.statusCode != 200) {
                      setState(() {
                        errorMessage = json.decode(signInApi!.body)['msg']['en'];
                      });
                    } else {
                      setState(() {
                        errorMessage = json.decode(signInApi.body)['msg']['en'];
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
                // Add a container to display the error message
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: errorMessage != null ? Text(errorMessage, style: TextStyle(color: Colors.red)) : SizedBox() 
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Response?> _signInApi() async {
    var configApi = await ConfigurationApi(apiUrl.text).execute();
    if (configApi!.statusCode != 200){
      return null;
    }
    Map<String, dynamic> configResponse = json.decode(configApi!.body);
    print(configApi.body);
    print(configApi.statusCode);

    RegExp regExp = RegExp(configResponse['password_rule']);
    if (!regExp.hasMatch(password.text)){
      return null;
    }

    String secretString = Crypto.hash().sha(utf8.encode(login.text+password.text+privateKey.text)).toString();
    var signInApi = await SignInApi(
      apiUrl.text,
      login.text,
      secretString,
      int.parse(tokenExpiration.text),
      oneTimeOrBackupCode.text,
      _selectedOption!
    ).execute();

    if (signInApi!.statusCode != 200){
      return signInApi;
    }

    String token = json.decode(signInApi.body)['token'];
    print(signInApi.request);

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
    await db.into(db.modelUser)
      .insert(
        modelUser,
        onConflict: drift.DoUpdate((_)=>modelUser, target: [db.modelUser.login]), 
      );
    await db.into(db.modelSettings)
      .insert(
        modelSettings,
        onConflict: drift.DoUpdate((_)=>modelSettings, target: [db.modelSettings.key]), 
      );
    return signInApi;
  }
}