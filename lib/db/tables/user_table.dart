import 'package:drift/drift.dart';

class ModelUser extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get login => text().unique().nullable()();
  TextColumn get secretString => text().unique().nullable()();
  TextColumn get accessToken => text().unique().nullable()();
}