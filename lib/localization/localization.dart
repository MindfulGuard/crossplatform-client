import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:drift/drift.dart' as drift;

class Localization{
  static const defaultLanguage = "en";
  static const dbSettingsKeyName = "language";
  static final _db = AppDb();

  static String get currentSystemLocale => Platform.localeName.substring(0,2);

  /// Returns a list of supported locales based on the specified type parameter.
  /// If the type parameter is String, it returns a list of language codes as strings.
  /// If the type parameter is Locale, it returns the entire list of supported locales.
  /// Throws a TypeError if the type parameter is neither String nor Locale.
  /// 
  /// @return A list of supported locales based on the specified type parameter.
  /// @throws TypeError If the type parameter is not String nor Locale.
  static List<T> getSupportedLocales<T>() {
    if (T == String) {
      // Return the list of strings
      return AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toList() as List<T>;
    } else if (T == Locale) {
      // Return the list of locales
      return AppLocalizations.supportedLocales as List<T>;
    } else {
      throw TypeError;
    }
  }

  /// Returns the localization that is supported by the application.
  /// If the system localization is not contained in the supported localization, then "en" (English) is returned by default.
  static String getSupportedLocale(){
    List<String> supportedLocales = getSupportedLocales<String>();
    if (supportedLocales.contains(currentSystemLocale)){
      return currentSystemLocale;
    } else{
      return defaultLanguage;
    }
  }

  /// Returns language data
  static SimpleSelectStatement<$ModelSettingsTable, ModelSetting>
    get dbLanguageData => _db.select(_db.modelSettings)..where((val) => val.key.equals(dbSettingsKeyName));
  
  /// Returns the code of the language that was selected by the user,
  /// if there is no entry, then the language that is used in the system is written to the "settings" table,
  /// if the application does not support this language,
  /// then by default the language code will be "en" (English).
  static Future<String> getLocale() async{
    var language = await dbLanguageData.getSingleOrNull();

    if (language?.key != null && language?.value != null){
      // If the language is still supported by the application, [language.value] is returned, and if not, [defaultLanguage] is returned.
      if (getSupportedLocales<String>().contains(language!.value)){
        return language.value!;
      } else{
        return defaultLanguage;
      }
    } else{
      // If no language is defined, a new key-value "language", <language>, is written to the "settings" table.
      String locale = getSupportedLocale();

      final entitySettings = ModelSettingsCompanion(
        key: drift.Value(dbSettingsKeyName),
        value: drift.Value(locale)
      );
    
      await _db.into(_db.modelSettings)
        .insert(
          entitySettings,
          onConflict: drift.DoUpdate((_)=>entitySettings, target: [_db.modelSettings.key])
        );

      return locale;
    }
  }
}