import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/user/delete_account.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/components/text_filelds.dart';

class DeleteAccountPrivacySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  DeleteAccountPrivacySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _DeleteAccountPrivacySettingsPagePrivacySettingsPageState createState() => _DeleteAccountPrivacySettingsPagePrivacySettingsPageState();
}

class _DeleteAccountPrivacySettingsPagePrivacySettingsPageState extends State<DeleteAccountPrivacySettingsPage>{
  TextEditingController oneTimeCodeController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    oneTimeCodeController.dispose();
  }

  Future<void> _deleteAccount() async{
    var db = AppDb();
    var result = await db.select(db.modelUser).getSingle();
    if (result.login == null){
      return;
    }

    String secretString = Crypto.hash().sha(utf8.encode(result.login!+result.password!+result.privateKey!)).toString();

    var api = DeleteAccountApi(
      buildContext: context,
      apiUrl: widget.apiUrl, 
      token: widget.token, 
      secretString: secretString, 
      oneTimeCode: oneTimeCodeController.text
    );

    await api.execute();

    if (api.response.statusCode != 200){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedDeleteAccount),
        ),
      );
      return;
    } else{
      await db.delete(db.modelSettings).go();
      await db.delete(db.modelUser).go();
      RestartWidget.restartApp(context);
    }
  }

  Future<void> _showWarningDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.warning),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.deleteAccountWarning),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: (){
                _deleteAccount();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AlignTextField(
                maxLength: 6,
                labelText: AppLocalizations.of(context)!.oneTimeCode,
                keyboardType: TextInputType.number,
                controller: oneTimeCodeController,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _showWarningDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.black,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: TextStyle(
                    fontSize: 18.0,
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