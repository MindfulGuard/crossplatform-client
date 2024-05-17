import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/logger/logs.dart';

class TextFontFamily{
  String fontFamilyDefault = "Roboto";
  final _db = AppDb();

  List<String> getAllAvailableFonts(){
    Map<String, dynamic> fontsMap = GoogleFonts.asMap();
    List<String> keys = fontsMap.keys.toList();
    return keys;
  }

  Future<String?> getAppFontFamily() async{
    var result = await (_db.select(_db.modelSettings)..where((tbl) => tbl.key.equals("textFontFamily"))).getSingleOrNull();
    if (result == null || result.value == ""){
      return null;
    } else{
      return result.value;
    }
  }

  Future<bool> setAppFontFamily(String value) async{
    try{
      final modelSettings = ModelSettingsCompanion(
        key: drift.Value('textFontFamily'),
        value: drift.Value(value)
      );
      await _db.into(_db.modelSettings).insert(
        modelSettings,
        onConflict: drift.DoUpdate((_) => modelSettings, target: [_db.modelSettings.key])
      );
      return true;
    } catch(e){
      AppLogger.logger.e("Failed to change the font-family in the database. $e");
      return false;
    }
  }

  Future<String> init() async{
    var fontFamily = await getAppFontFamily();

    AppLogger.logger.i("Current font-family: ${fontFamily ?? fontFamilyDefault}");

    if (fontFamily == null || fontFamily.isEmpty){
      await setAppFontFamily(fontFamilyDefault);
      return fontFamilyDefault;
    } else{
      return fontFamily;
    }
  }
}