import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rapidmap_test/to_do_list/database.dart' as database;
import 'package:rapidmap_test/to_do_list/task.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Task> _tasks = [];
  late Future<void> _tasksFuture = _initTasks();

  Future<void> _initTasks() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _tasks = await database.getTasks();
  }

  Future<void> _refreshTasks() async {
    final tasks = await database.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  void initState() {
    super.initState();
    _tasksFuture = _initTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "To-Do List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<void>(
          future: _tasksFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ));

              case ConnectionState.done:
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshTasks,
                  child: _tasks.isNotEmpty
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _tasks.length,
                          itemBuilder: (BuildContext context, index) =>
                              ListTile(
                            title: Text(_tasks[index].title),
                          ),
                        )
                      : const Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Add a new task',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        onPressed: _addTask,
        tooltip: 'Add a new task',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Card _buildTask(Task task) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(
          task.description,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.edit),
      ),
    );
  }

  void _addTask() {
    showModalBottomSheet(context: context, builder: (context) => Container());
  }
}
