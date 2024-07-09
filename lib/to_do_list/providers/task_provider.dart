import 'package:flutter/material.dart';
import 'package:rapidmap_test/to_do_list/models/database.dart';
import 'package:rapidmap_test/to_do_list/models/task.dart';

/// Manage Task data and notify listeners of any changes.
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper.helper;

  List<Task> get tasks => _tasks;

  Future<void> getTasks() async {
    _tasks = await _databaseHelper.getTasks();
    notifyListeners();
  }

  Future<void> insertTask(Task newTask) async {
    await _databaseHelper.insertTask(newTask);
    await getTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    await _databaseHelper.updateTask(updatedTask);
    await getTasks();
  }

  Future<void> updateTaskCompletion(Task task, int status) async {
    await _databaseHelper.updateCompletionStatus(task, status);
    await getTasks();
  }

  Future<void> deleteTask(int id) async {
    await _databaseHelper.deleteTask(id);
    await getTasks();
  }

  void sortTasksByDueDate(bool ascending) {
    _tasks.sort((Task t1, Task t2) {
      if (ascending) {
        return t1.dueDate.compareTo(t2.dueDate);
      } else {
        return t2.dueDate.compareTo(t1.dueDate);
      }
    });
    notifyListeners();
  }
}
