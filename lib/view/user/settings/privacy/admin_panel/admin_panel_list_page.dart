import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/user/settings/privacy/admin_panel/settings_page.dart';
import 'package:mindfulguard/view/user/settings/privacy/admin_panel/users_page.dart';

class AdminPanelListPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  AdminPanelListPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _AdminPanelListPageState createState() => _AdminPanelListPageState();
}

class _AdminPanelListPageState extends State<AdminPanelListPage>{
  List<Map<String, dynamic>> settings = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      settings = [
        {'name': AppLocalizations.of(context)!.serverSettings, 'icon': Icons.settings_suggest_rounded},
        {'name': AppLocalizations.of(context)!.userManagement, 'icon': Icons.supervised_user_circle_outlined},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminPanel),
      ),
      body: ListView.builder(
        itemCount: settings.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(settings[index]['icon']),
            title: Text(
              settings[index]['name'],
            ),
            onTap: () {
              if (settings[index]['name'] == AppLocalizations.of(context)!.serverSettings) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsSettingsAdminPage(
                    apiUrl: widget.apiUrl,
                    token: widget.token,
                  )),
                );
              } else if (settings[index]['name'] == AppLocalizations.of(context)!.userManagement) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersSettingsAdminPage(
                    apiUrl: widget.apiUrl,
                    token: widget.token,
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
