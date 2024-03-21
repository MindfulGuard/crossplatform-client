import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/view/components/passcode_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/delete_account.dart';
import 'package:mindfulguard/view/user/settings/privacy/devices_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/qr_code_login_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/set_passcode_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/update_one_time_code_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/update_password_and_private_key.dart';

class ListPrivacySettingsPagePasscodePrivacySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  ListPrivacySettingsPagePasscodePrivacySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _ListPrivacySettingsPagePasscodePrivacySettingsPageState createState() => _ListPrivacySettingsPagePasscodePrivacySettingsPageState();
}

class _ListPrivacySettingsPagePasscodePrivacySettingsPageState extends State<ListPrivacySettingsPagePasscodePrivacySettingsPage> {
  final _db = AppDb();
  String? _passcode;

  @override
  void initState() {
    super.initState();
    _isAuth();
    _passcodeExists();
  }

  Future<void> _isAuth() async{
    var response = UserInfoApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token 
    );

    await response.execute();

    if (response.response == null){
      Navigator.pop(context);
    } else if(response.response.statusCode == 401){
      Navigator.pop(context);
    }
  }

  Future<void> _passcodeExists() async {
    var result = await (_db.select(_db.modelSettings)..where((tbl) => tbl.key.equals("passcode"))).getSingleOrNull();

    if (result == null) {
      setState(() {
        _passcode = "";
      });
    } else {
      setState(() {
        _passcode = result.value!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    if (_passcode == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.localPasscode),
        ),
        body: Container(),
      );
    } else if (_passcode!.isEmpty) {
      return ListPrivacySettingsPage(
        apiUrl: widget.apiUrl,
        token: widget.token,
      );
    } else {
      return InsertPasscodePage(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.localPasscode),
        ),
        passcodeSuccess: (){
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListPrivacySettingsPage(
              apiUrl: widget.apiUrl,
              token: widget.token,
            )),
          );
        },
        passcode: _passcode!,
      );
    }
  }
}

class ListPrivacySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  ListPrivacySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _ListPrivacySettingsPageState createState() => _ListPrivacySettingsPageState();
}

class _ListPrivacySettingsPageState extends State<ListPrivacySettingsPage>{
  List<Map<String, dynamic>> settings = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      settings = [
        {'name': AppLocalizations.of(context)!.devices, 'icon': Icons.devices},
        {'name': AppLocalizations.of(context)!.qrCodeLogin, 'icon': Icons.qr_code_rounded},
        {'name': AppLocalizations.of(context)!.localPasscode, 'icon': Icons.password},
        {'name': AppLocalizations.of(context)!.updateOneTimeCode, 'icon': Icons.security},
        {'name': AppLocalizations.of(context)!.updatePasswordAndPrivateKey, 'icon': Icons.security},
        {'name': AppLocalizations.of(context)!.deleteAccount, 'icon': Icons.remove_circle_outline},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacy),
      ),
      body: ListView.builder(
        itemCount: settings.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(settings[index]['icon']), // Icon on the left
            title: Text(
              settings[index]['name'],
            ),
            onTap: () {
              if (settings[index]['name'] == AppLocalizations.of(context)!.devices) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DevicesSettingsPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.qrCodeLogin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QrCodeLoginPrivacySettingsPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.localPasscode) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetPasscodePrivacySettingsPage()),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.updateOneTimeCode) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateOneTimeCodePrivacySettingsPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.updatePasswordAndPrivateKey) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdatePasswordAndPrivateKeyPrivacySettingsPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.deleteAccount) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteAccountPrivacySettingsPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
