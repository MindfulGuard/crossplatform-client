import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';

class SetPasscodePrivacySettingsPage extends StatefulWidget {

  SetPasscodePrivacySettingsPage({
    Key? key
  }) : super(key: key);

  @override
  _SetPasscodePrivacySettingsPageState createState() => _SetPasscodePrivacySettingsPageState();
}

class _SetPasscodePrivacySettingsPageState extends State<SetPasscodePrivacySettingsPage>{
  final _db = AppDb();
  TextEditingController _passcodeController = TextEditingController();
  TextEditingController _rePasscodeController = TextEditingController();

  bool isDesktop = true;
  bool passCodeExists = false;

  @override
  void initState(){
    super.initState();
    _isDesktop();
    _passCodeExists();
  }

  @override
  void dispose(){
    super.dispose();
    _passcodeController.dispose();
    _rePasscodeController.dispose();
  }

  void _isDesktop() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS){
      setState(() {
        isDesktop = true;
      });
    } else {
      setState(() {
        isDesktop = false;
      });
    }
  }

  Future<void> _passCodeExists() async{
    var result = await (_db.select(_db.modelSettings)..where((tbl) => tbl.key.equals("passcode"))).getSingleOrNull();
    if (result == null){
      setState(() {
        passCodeExists = false;
      });
    } else{
      setState(() {
        passCodeExists = true;
      });
    }
  }

  Future<void> _setPasscode() async{
    if (
      _passcodeController.text.isEmpty || _rePasscodeController.text.isEmpty
      || _passcodeController.text != _rePasscodeController.text
    ){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidValue),
        ),
      );
      return;
    }
    
    var result = await (_db.select(_db.modelSettings)..where((tbl) => tbl.key.equals("passcode"))).getSingleOrNull();
    
    final modelSettings = ModelSettingsCompanion(
      key: const drift.Value('passcode'),
      value: drift.Value(Crypto.hash().sha(_passcodeController.text).toString())
    );

    if (result == null){
      if(await _db.into(_db.modelSettings).insert(modelSettings) > 0){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passcodeWasSuccessfullyChanged),
          ),
        );
        RestartWidget.restartApp(context);
        // Navigator.pop(context);
        return; // Successfully
      }
    } else{
      if (await (_db.update(_db.modelSettings)..where((tbl) => tbl.key.equals('passcode'))).write(
        modelSettings
      ) > 0){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passcodeWasSuccessfullyChanged),
          ),
        );
        // Navigator.pop(context);
        RestartWidget.restartApp(context);
        return; // Successfully
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToChangePasscode),
          ),
        );
      }
    }
  }

  Future<void> _disablePasscode() async{
    var result = await (_db.delete(_db.modelSettings)..where((tbl) => tbl.key.equals("passcode"))).go();
    if (result > 0){
      setState(() {
        passCodeExists = false;
      });
      RestartWidget.restartApp(context);
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.localPasscode),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialogRowWindow(
                    title: AppLocalizations.of(context)!.helpReference,
                    content: [
                      Text(AppLocalizations.of(context)!.passCodeInfo),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.passCodeInfoPartTwo)
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.setNewPasscode,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: isDesktop ? TextInputType.text : TextInputType.number,
              inputFormatters: isDesktop ? null : <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: _passcodeController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.enterPasscode,
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: isDesktop ? TextInputType.text : TextInputType.number,
              inputFormatters: isDesktop ? null : <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: _rePasscodeController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.reEnterPasscode,
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _setPasscode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                AppLocalizations.of(context)!.submitPasscode,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            passCodeExists
            ? Expanded(
              child: ListView(
                reverse: true,
                children: [
                  TextButton(
                    onPressed: _disablePasscode,
                    style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red.withAlpha(125)),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.red.withOpacity(0.7);
                          }
                          return Colors.transparent;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    child: Text(
                      style: TextStyle(
                        fontSize: 21,
                      ),
                      AppLocalizations.of(context)!.disable,
                    ),
                  ),
                ],
              ),
            )
            : Container()
          ],
        ),
      ),
    );
  }
}
