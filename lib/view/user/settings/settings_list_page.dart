import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/user/settings/language_page.dart';

class SettingsListPage extends StatefulWidget {
  Map<String, dynamic> userInfoApi;
  final String apiUrl;
  final String token;

  SettingsListPage({
    required this.userInfoApi,
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
        {'name': AppLocalizations.of(context)!.language, 'icon': Icons.language},
        // Add more settings as needed
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
              // Открываем определенную страницу в зависимости от нажатой кнопки
              if (settings[index]['name'] == AppLocalizations.of(context)!.language) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LanguageSettingsPage(
                    userInfoApi: widget.userInfoApi,
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
