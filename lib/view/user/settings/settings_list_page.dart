import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:mindfulguard/view/user/settings/application_info_page.dart';
import 'package:mindfulguard/view/user/settings/audit_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/devices_page.dart';
import 'package:mindfulguard/view/user/settings/language_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/privacy_list_page.dart';

class SettingsListPage extends StatefulWidget {
  Map<String, dynamic> userInfoApi;
  List<dynamic> devicesInfoApi;
  final String apiUrl;
  final String token;

  SettingsListPage({
    required this.userInfoApi,
    required this.devicesInfoApi,
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _SettingsListPageState createState() => _SettingsListPageState();
}

class _SettingsListPageState extends State<SettingsListPage>{
  List<Map<String, dynamic>> settings = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      settings = [
        {'name': AppLocalizations.of(context)!.language, 'icon': Icons.translate},
        {'name': AppLocalizations.of(context)!.privacy, 'icon': Icons.lock_outline},
        {'name': AppLocalizations.of(context)!.auditLog, 'icon': Icons.auto_stories},
        {'name': AppLocalizations.of(context)!.aboutApp, 'icon': Icons.info_outline},
      ];
    });
  }

  void __signOut() async{
    var tokenHash = Crypto.hash().sha(widget.token).toString().substring(0, 28); // Hashing the token and extracts the first 28 characters.

    String tokenIdResult = "";
  
    for (var val in widget.userInfoApi['tokens']){
      if (val['short_hash'] == null){ // Checks if the "short_hash" key exists.
        return;
      } else{
        if (val['short_hash'] == tokenHash){ // Retrieves the token id if the token hash matches the one found.
          tokenIdResult = val['id'];
          break;
        }
      }
    }

    var api = await SignOutApi(widget.apiUrl, tokenIdResult, widget.token).execute();
    if (api?.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
    } else{
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          IconButton(
            color: Colors.red,
            onPressed: __signOut,
            icon: Icon(Icons.logout),
          ),
          ],
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
              // Open a specific page depending on the button pressed
              if (settings[index]['name'] == AppLocalizations.of(context)!.language) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LanguageSettingsPage(
                    token: widget.token,
                    apiUrl: widget.apiUrl,
                  )),
                );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.privacy) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyListPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.auditLog) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuditSettingsPage(
                      token: widget.token,
                      apiUrl: widget.apiUrl,
                    )),
                  );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.aboutApp) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ApplicationInfoSettingsPage()),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
