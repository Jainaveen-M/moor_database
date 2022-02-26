import 'dart:async';
import 'dart:developer';
import 'package:database/locator.dart';
import 'package:flutter/material.dart';
import 'package:database/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Todo> todo = [];
  TextEditingController _title = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _prio = TextEditingController();
  TextEditingController _tag = TextEditingController();
  @override
  void initState() {
    super.initState();
    getTodo();
  }

  getTodo() async {
    todo = await AppDatabase().getTodoList();
    log(todo.length.toString());
    streamTodo();
  }

  Stream<List<Todo>> streamTodo() async* {
    todo = await AppDatabase().getTodoList();
    yield todo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Moor database operations"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _title,
                decoration: InputDecoration(
                  hintText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _desc,
                decoration: InputDecoration(
                  hintText: "Desc",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _prio,
                decoration: InputDecoration(
                  hintText: "Priority",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _tag,
                decoration: InputDecoration(
                  hintText: "Tag",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            //by using future builder
            // Expanded(
            //   child: FutureBuilder<List<Todo>>(
            //     future: _appDatabase.getTodoList(),
            //     builder: (context, snapshot) => ListView.builder(
            //       itemCount: snapshot.data!.length,
            //       itemBuilder: (context, index) => GestureDetector(
            //         onDoubleTap: () {
            //           _appDatabase.deleteTodo(todo[index].id);
            //           setState(() {});
            //         },
            //         onTap: () {
            //           setState(() {
            //             _title.text = todo[index].title;
            //             _desc.text = todo[index].content;
            //           });
            //         },
            //         child: Container(
            //           margin: const EdgeInsets.all(10),
            //           padding: const EdgeInsets.all(10),
            //           color: Colors.grey[200],
            //           child: Column(
            //             children: [
            //               Text(todo[index].id.toString()),
            //               Text(todo[index].title),
            //               Text(todo[index].content),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            //by using stream builder
            Expanded(
              child: StreamBuilder<List<Todo>>(
                stream: sl<AppDatabase>().watchTodoList(),
                builder: ((context, AsyncSnapshot<List<Todo>> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text("Loading..."),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onDoubleTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Delete todo"),
                                content: const Text(
                                    "Do you really want to delete this todo?"),
                                actions: [
                                  GestureDetector(
                                    child: const Text("Delete"),
                                    onTap: () {
                                      sl<AppDatabase>()
                                          .deleteTodo(todo[index].id);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      onTap: () {
                        setState(() {
                          _title.text = todo[index].title;
                          _desc.text = todo[index].content;
                          _prio.text = todo[index].priority ?? '';
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey[200],
                        child: Column(
                          children: [
                            Text(todo[index].title),
                            Text(todo[index].content),
                            Text(todo[index].priority ?? ''),
                            // Text(todo[index].tag ?? ''),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              child: const Text("Add"),
              onPressed: () {
                sl<AppDatabase>().insertTodo(
                  TodosCompanion(
                    title: drift.Value(_title.text),
                    content: drift.Value(_desc.text),
                    priority: drift.Value(_prio.text),
                    // tag: drift.Value(_tag.text),
                  ),
                );
                _title.clear();
                _desc.clear();
                _prio.clear();
                _tag.clear();
                getTodo();
                setState(() {});
              },
            ),
            FloatingActionButton(
              child: const Text("Up"),
              onPressed: () {
                sl<AppDatabase>().updateTodo(
                  TodosCompanion(
                    title: drift.Value(_title.text),
                    content: drift.Value(_desc.text),
                    priority: drift.Value(_prio.text),
                    // tag: drift.Value(_tag.text),
                  ),
                );
                _title.clear();
                _desc.clear();
                _prio.clear();
                _tag.clear();
                getTodo();
                setState(() {});
              },
            ),
          ],
        ));
  }
}
