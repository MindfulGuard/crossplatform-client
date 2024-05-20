import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ru.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';

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
        title: Text(AppLocalizations.of(context)!.language),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialogWindow(
                    title: AppLocalizations.of(context)!.helpReference,
                    content: AppLocalizations.of(context)!.selectedLanguageWillBeUsedAsPrimaryLanguageInApplication,
                  );
                },
              );
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: languagesInfo.length,
        itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (_selectedLanguage != languagesInfo[index]['englishLanguageName']) {
              _showConfirmationDialog(languagesInfo[index]['englishLanguageName']!);
            }
          },
          child: ListTile(
            title: Text(languagesInfo[index]['originalLanguageName']!),
            subtitle: Text(languagesInfo[index]['englishLanguageName']!),
            trailing: (){
              if (_selectedLanguage == languagesInfo[index]['englishLanguageName']){
                return Icon(Icons.done);
              }
              return null;
            }()
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
      builder: (context) => AlertDialogWindow(
        title: AppLocalizations.of(context)!.languageChangeConfirmation,
        content: AppLocalizations.of(context)!.languageChangeRequest,
        closeButtonText:  AppLocalizations.of(context)!.cancel,
        secondButtonText: AppLocalizations.of(context)!.ok,
        onSecondButtonPressed: (){
          _changeLanguage(languageName);
          Navigator.of(context).pop();
        },
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