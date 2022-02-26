import 'dart:developer';
import 'dart:io';
import 'package:database/database/todos/todo.dart';
import 'package:path/path.dart' as path;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          log("from database :$from");
          log("to database : $to");
          if (from < 2) {
           await m.addColumn(todos, todos.priority);
          }
        },
      );

  //Insert
  Future<int> insertTodo(TodosCompanion todo) async {
    return await into(todos).insert(todo);
  }

  //Get
  Future<List<Todo>> getTodoList() async {
    return await select(todos).get();
  }

  //Get by stream
  Stream<List<Todo>> watchTodoList() => select(todos).watch();

  //DELETE
  Future<int> deleteTodo(int todoId) async {
    return await (delete(todos)..where((tbl) => tbl.id.equals(todoId))).go();
    //return await delete(todos).delete(todo);
  }

  //Update
  Future<bool> updateTodo(TodosCompanion todo) async {
    return await update(todos).replace(todo);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    log("dp path : ${dbFolder.path}");
    final file = File(path.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
