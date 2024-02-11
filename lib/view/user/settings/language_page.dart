import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ru.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mindfulguard/restart_widget.dart';

class LanguageSettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  const LanguageSettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  late String _selectedLanguage;
  List<Map<String, String>> languagesInfo = [];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = '';
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _selectedLanguage = AppLocalizations.of(context)?.englishLanguageName ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (languagesInfo.isEmpty) {
      _populateLanguageInfo();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.language ?? ''),
      ),
      body: ListView.builder(
        itemCount: languagesInfo.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(languagesInfo[index]['originalLanguageName']!),
            subtitle: Text(languagesInfo[index]['englishLanguageName']!),
            trailing: Radio<String>(
              value: languagesInfo[index]['englishLanguageName']!,
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                _showConfirmationDialog(value!);
              },
            ),
          );
        },
      ),
    );
  }

  void _populateLanguageInfo() {
    final List<AppLocalizations> appLocalizations = [
      AppLocalizationsEn(),
      AppLocalizationsRu()
    ];
    for (var val in appLocalizations) {
      languagesInfo.add({
        "languageCode": val.languageCode!,
        "englishLanguageName": val.englishLanguageName!,
        "originalLanguageName": val.originalLanguageName!,
      });
    }
  }

  void _showConfirmationDialog(String languageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.languageChangeConfirmation),
        content: Text(AppLocalizations.of(context)!.languageChangeRequest),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: (){
              _changeLanguage(languageName);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  String _getLanguageCode(String englishLanguageName) {
    for (var languageInfo in languagesInfo) {
      if (languageInfo['englishLanguageName'] == englishLanguageName) {
        return languageInfo['languageCode']!;
      }
    }
    return 'en';
  }

  void _changeLanguage(String languageName) async{
    setState(() {
      _selectedLanguage = languageName;
    });
    final db = AppDb();
    var result = await (db.update(db.modelSettings)
      ..where((tbl) => tbl.key.equals(Localization.dbSettingsKeyName))
    ).write(
      ModelSettingsCompanion(
        value: drift.Value(_getLanguageCode(languageName))
      ),
    );

    if (result > 0){
      RestartWidget.restartApp(context);
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToChangeLanguage),
        ),
      );
    }
  }
}