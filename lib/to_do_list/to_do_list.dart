import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidmap_test/to_do_list/forms/task_input_form.dart';
import 'package:rapidmap_test/to_do_list/providers/task_provider.dart';
import 'package:rapidmap_test/to_do_list/utils/datetime_utils.dart' as utils;
import 'package:rapidmap_test/to_do_list/models/task.dart';
import 'package:rapidmap_test/to_do_list/utils/snackbar_utils.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  /// Enables pull-to-refresh functionality.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  /// Default sort order.
  bool _ascending = true;

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
          future: _fetchTasks(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            final taskProvider = Provider.of<TaskProvider>(context);
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
                  onRefresh: _fetchTasks,
                  child: taskProvider.tasks.isNotEmpty
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: taskProvider.tasks.length,
                          itemBuilder: (BuildContext context, int index) =>
                              _buildTask(taskProvider.tasks[index]),
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
        onPressed: () => _inputTask(null),
        tooltip: 'Add a new task',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds a single Task widget.
  Card _buildTask(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    return Card(
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: task.completed > 0
            ? GestureDetector(
                onTap: () => taskProvider.updateTaskCompletion(task, 0),
                child: const Icon(
                  Icons.check_circle,
                  size: 25,
                  color: Colors.blueAccent,
                ),
              )
            : GestureDetector(
                onTap: () => taskProvider.updateTaskCompletion(task, 1),
                child: const Icon(Icons.check_circle_outline, size: 25),
              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: const TextStyle(color: Colors.black, fontSize: 12, fontStyle: FontStyle.italic),
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
                  utils.formatDate(task.dueDate),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _inputTask(task),
              child: const Icon(Icons.edit, size: 25, color: Colors.deepPurple),
            ),
            GestureDetector(
              onTap: () => _deleteTask(task.id!),
              child: const Icon(Icons.delete, size: 25),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetch tasks from TaskProvider.
  Future<void> _fetchTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.getTasks();
  }

  /// Insert or update a Task.
  void _inputTask(Task? inputTask) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: inputTask != null
                ? TaskInputForm(task: inputTask)
                : const TaskInputForm(),
          ),
        ),
      ),
    );
  }

  /// Shows Task deletion confirmation dialog.
  void _deleteTask(int taskId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete task'),
        content: const Text('Deletion cannot be reversed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(taskId);
              showSnackBar(context, 'Task deleted');
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
