import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/user/settings/application_info_page.dart';
import 'package:mindfulguard/view/user/settings/audit_page.dart';
import 'package:mindfulguard/view/user/settings/devices_page.dart';
import 'package:mindfulguard/view/user/settings/language_page.dart';

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
        {'name': AppLocalizations.of(context)!.devices, 'icon': Icons.devices},
        {'name': AppLocalizations.of(context)!.auditLog, 'icon': Icons.auto_stories},
        {'name': AppLocalizations.of(context)!.aboutApp, 'icon': Icons.info_outline},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
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
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.devices) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DevicesSettingsPage(
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
