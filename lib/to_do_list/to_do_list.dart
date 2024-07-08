import 'package:flutter/material.dart';
import 'package:rapidmap_test/to_do_list/database.dart';
import 'package:rapidmap_test/to_do_list/helper.dart';
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

  final DatabaseHelper databaseHelper = DatabaseHelper.helper;

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
                          itemBuilder: (BuildContext context, int index) =>
                              _buildTask(_tasks[index]),
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
        leading: task.completed > 0
            ? GestureDetector(
                onTap: () => _updateTask(task, 0),
                child: const Icon(
                  Icons.check_circle,
                  size: 25,
                  color: Colors.blueAccent,
                ),
              )
            : GestureDetector(
                onTap: () => _updateTask(task, 1),
                child: const Icon(Icons.check_circle_outline, size: 25),
              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: const TextStyle(color: Colors.black, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  formatDate(task.dueDate),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.edit, size: 25),
      ),
    );
  }

  void _addTask() {
    showModalBottomSheet(context: context, builder: (context) => Container());
  }

  Future<void> _initTasks() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _tasks = await databaseHelper.getTasks();
    _tasks = [
      Task(
        id: 1,
        title: 'Test 1',
        description: 'Test desc',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      ),
      Task(
        id: 2,
        title: 'Test 2',
        description: 'Test desc longggggggggggggggggggggggggggggggggggggg',
        dueDate: DateTime.now().millisecondsSinceEpoch + 10000,
        completed: 1,
      )
    ];
  }

  Future<void> _refreshTasks() async {
    final tasks = await databaseHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _updateTask(Task task, int status) async {
    await databaseHelper.updateCompletionStatus(task, status);
    _refreshTasks();
  }
}
