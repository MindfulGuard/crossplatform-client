import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/configuration.dart';
import 'package:mindfulguard/net/api/user/update_secret_string.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';
import 'package:mindfulguard/view/components/text_filelds.dart';
import 'package:uuid/uuid.dart';

class UpdatePasswordAndPrivateKeyPrivacySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  UpdatePasswordAndPrivateKeyPrivacySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _UpdatePasswordAndPrivateKeyPrivacySettingsPageState createState() => _UpdatePasswordAndPrivateKeyPrivacySettingsPageState();
}

class _UpdatePasswordAndPrivateKeyPrivacySettingsPageState extends State<UpdatePasswordAndPrivateKeyPrivacySettingsPage>{
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController oneTimeCodeController = TextEditingController();
  String newPrivateKey = "";
  bool isUpdated = false;
  Widget info = Container();


  @override
  void dispose(){
    super.dispose();
    newPasswordController.dispose();
    oneTimeCodeController.dispose();
  }

  void _buildInfo(){
    setState(() {
      info = Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.privateKey}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(newPrivateKey),
            SizedBox(height: 15,),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: (){
                  return newPrivateKey;
                }()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.valueCopiedToClipboard),
                  ),
                );
              },
              icon: Icon(Icons.copy),
              label: Text(AppLocalizations.of(context)!.copy),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _updateSecretString() async{
    var db = AppDb();
    var result = await db.select(db.modelUser).getSingle();
    if (result.login == null){
      return;
    }

    if(result.password == newPasswordController.text){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidValue),
        ),
      );
      return;
    }

    String oldSecretString = Crypto.hash().sha(utf8.encode(result.login!+result.password!+result.privateKey!)).toString();

    setState(() {
      newPrivateKey = const Uuid().v4();
    });
    String newSecretString = Crypto.hash().sha(utf8.encode(result.login!+newPasswordController.text+newPrivateKey)).toString();

    var api = UpdateSecretStringApi(
      buildContext: context,
      apiUrl: widget.apiUrl, 
      token: widget.token,
      oldSecretString: oldSecretString,
      newSecretString: newSecretString,
      oneTimeCode: oneTimeCodeController.text
    );

    await api.execute();

    if (api.response.statusCode != 200){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedUpdatePasswordAndPrivateKey),
        ),
      );
      return;
    } else{
      setState(() {
        isUpdated = true;
      });

      await db.delete(db.modelSettings).go();
      await db.delete(db.modelUser).go();
      _buildInfo();
    }
  }

  Future<void> _showWarningDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialogWindow(
          title: AppLocalizations.of(context)!.warning,
          content: AppLocalizations.of(context)!.updatePasswordAndPrivateKeyWarning,
          secondButtonText: AppLocalizations.of(context)!.yes,
          closeButtonText: AppLocalizations.of(context)!.cancel,
          onSecondButtonPressed: (){
            _updateSecretString();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updatePasswordAndPrivateKey),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialogWindow(
                    title: AppLocalizations.of(context)!.helpReference,
                    content: [
                      Text(AppLocalizations.of(context)!.updatePasswordAndPrivateKeyInfo),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.updatePasswordAndPrivateKeyPasswordInfo),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.updatePasswordAndPrivateKeyOneTimeCodeInfo),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.updatePasswordAndPrivateKeyWarningInfo),
                      SizedBox(height: 10),
                    ]
                  );
                },
              );
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AlignTextField(
                labelText: AppLocalizations.of(context)!.newPassword,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                controller: newPasswordController,
              ),
              SizedBox(height: 30),
              AlignTextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                labelText: AppLocalizations.of(context)!.oneTimeCode,
                keyboardType: TextInputType.number,
                controller: oneTimeCodeController,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isUpdated
                ? (){
                  RestartWidget.restartApp(context);
                }
                : () async{
                    var configApi = ConfigurationApi(
                      apiUrl: widget.apiUrl
                    );
                    await configApi.execute();

                    if (configApi.response.statusCode != 200){
                      return;
                    }
                    Map<String, dynamic> configResponse = json.decode(configApi.response.body);

                    RegExp regExp = RegExp(configResponse['password_rule']);
                    if (
                      !regExp.hasMatch(newPasswordController.text)
                      || newPasswordController.text.isEmpty 
                      || oneTimeCodeController.text.isEmpty
                      || oneTimeCodeController.text.length != 6
                    ){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.invalidValue),
                        ),
                      );
                      } else{
                        await _showWarningDialog();
                      }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isUpdated ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.update,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              SizedBox(height: 30,),
              info
            ],
          )
        )
      ),
    );
  }
}