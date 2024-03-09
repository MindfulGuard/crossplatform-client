import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mindfulguard/db/tables/settings_table.dart';
import 'package:mindfulguard/db/tables/user_table.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [ModelUser, ModelSettings])
class AppDb extends _$AppDb {
  // Create a private static instance variable for the singleton pattern
  static AppDb? _instance;

  // Private constructor to prevent instantiation from outside
  AppDb._(QueryExecutor e) : super(e);

  // Public factory method to provide access to the singleton instance
  factory AppDb() {
    _instance ??= AppDb._(_openConnection());
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'mindfulguard.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}