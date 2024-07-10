import 'package:flutter/material.dart';
import 'package:rapidmap_test/to_do_list/models/database.dart';
import 'package:rapidmap_test/to_do_list/models/task.dart';

/// Manage Task data and notify listeners of any changes.
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper.helper;

  List<Task> get tasks => _tasks;

  /// Fetch all [Task]s from DB.
  Future<void> getTasks() async {
    _tasks = await _databaseHelper.getTasks();
    notifyListeners();
  }

  /// Insert a new [Task].
  Future<void> insertTask(Task newTask) async {
    await _databaseHelper.insertTask(newTask);
    await getTasks();
  }

  /// Update a given [Task]
  Future<void> updateTask(Task updatedTask) async {
    await _databaseHelper.updateTask(updatedTask);
    await getTasks();
  }

  /// Update completion status of a given [Task].
  Future<void> updateTaskCompletion(Task task, int status) async {
    await _databaseHelper.updateCompletionStatus(task, status);
    await getTasks();
  }

  /// Delete a [Task] from the DB.
  Future<void> deleteTask(int id) async {
    await _databaseHelper.deleteTask(id);
    await getTasks();
  }

  /// Sort [Task]s by their due date.
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
