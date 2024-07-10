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
  /// Returns [Task.id] if successful, and 0 otherwise.
  Future<int> insertTask(Task newTask) async {
    int result = await _databaseHelper.insertTask(newTask);
    await getTasks();
    return result;
  }

  /// Update a given [Task].
  /// Returns 1 if successful, 0 otherwise.
  Future<int> updateTask(Task updatedTask) async {
    int result = await _databaseHelper.updateTask(updatedTask);
    await getTasks();
    return result;
  }

  /// Update completion status of a given [Task].
  /// Returns 1 if successful, 0 otherwise.
  Future<int> updateTaskCompletion(Task task, int status) async {
    int result = await _databaseHelper.updateCompletionStatus(task, status);
    await getTasks();
    return result;
  }

  /// Delete a [Task] from the DB.
  /// Returns the numbers of rows deleted, or 0 on error.
  Future<int> deleteTask(int id) async {
    int result = await _databaseHelper.deleteTask(id);
    await getTasks();
    return result;
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
