import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/user/update_one_time_code.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/components/buttons.dart';
import 'package:mindfulguard/view/components/qr.dart';

class UpdateOneTimeCodePrivacySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  UpdateOneTimeCodePrivacySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _UpdateOneTimeCodePrivacySettingsPageState createState() => _UpdateOneTimeCodePrivacySettingsPageState();
}

class _UpdateOneTimeCodePrivacySettingsPageState extends State<UpdateOneTimeCodePrivacySettingsPage>{
  String codeType = '';
  Widget resultData = Container();

  void _buildResultData(dynamic data, String login) {
    if (data is String || data is List<dynamic>) {
      bool isDesktop = false;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        isDesktop = true;
      }

      setState(() {
        resultData = Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[200],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (data is String)
                    Text(
                      '${AppLocalizations.of(context)!.totpCode}:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isDesktop && data is String)
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: QrGenerator(
                                  size: 256,
                                  data: "otpauth://totp/$login?secret=$data&issuer=MindfulGuard",
                                ),
                              );
                            });
                      },
                      icon: Icon(Icons.qr_code_rounded),
                    ),
                ],
              ),
              if (data is String) Text(data),
              SizedBox(height: 8.0),
              if (data is List<dynamic>)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.backupCodes}:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...data.map((code) => Text(code.toString())).toList(),
                  ],
                ),
                SizedBox(height: 20,),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: (){
                      return "$data";
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
            ],
          ),
        );
      });
    } else {
      return;
    }
  }

  Future<void> _send() async{
    var db = AppDb();
    var result = await db.select(db.modelUser).getSingle();
    if (result.login == null){
      return;
    }

    String secretString = Crypto.hash().sha(utf8.encode(result.login!+result.password!+result.privateKey!)).toString();

    var api = UpdateOneTimeCodeApi(
      buildContext: context,
      apiUrl: widget.apiUrl, 
      token: widget.token,
      secretString: secretString,
      type: codeType
    );

    await api.execute();

    if (api.response.statusCode != 200){
      return;
    } else{
      _buildResultData(json.decode(api.response.body)['data'], result.login!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.updateOneTimeCode,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropDown(
                options: const ['basic', 'backup'],
                onOptionChanged: (String? selectedValue) {
                  codeType = selectedValue!;
                  AppLogger.logger.i("Selected one-time code type: $selectedValue");
                },
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.update,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              SizedBox(height: 30),
              resultData
            ],
          ),
        ),
      )
    );
  }
}