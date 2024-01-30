import 'package:drift/drift.dart';

class ModelSettings extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique().nullable()();
  TextColumn get value => text().nullable()();
}