import 'package:drift/drift.dart';

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 32)();
  TextColumn get content => text().named('body')();
  TextColumn get priority => text().withLength(min: 1, max: 30).nullable()();
}

@DriftDatabase(tables: [Todos])
class AppDatabase {}




//   TextColumn get priority => text().withLength(min: 1, max: 30).nullable()();
//   TextColumn get tag => text().withLength(min: 1, max: 30).nullable()();