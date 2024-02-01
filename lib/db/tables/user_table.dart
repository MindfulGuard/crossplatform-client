import 'package:drift/drift.dart';

class ModelUser extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get login => text().unique().nullable()();
  TextColumn get password => text().unique().nullable()();
  TextColumn get privateKey => text().unique().nullable()();
  TextColumn get accessToken => text().unique().nullable()();
}