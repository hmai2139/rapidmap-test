import 'package:flutter/cupertino.dart';

class OperationResult {

  /// Error messages.
  static const errorFetch = 'Could not fetch tasks';
  static const errorInsert = 'Could not add task';
  static const errorUpdate = 'Could not update task';
  static const errorDelete = 'Could not delete task';
  static const errorUpdateCompletionStatus =
      'Could not update completion status.';

  /// Success messages.
  static const successFetch = 'Tasks fetched';
  static const successInsert = 'Task added';
  static const successUpdate = 'Task updated';
  static const successDelete = 'Task deleted';
  static const successUpdateCompleted = 'Task marked as completed.';
  static const successUpdateUncompleted = 'Task marked as uncompleted.';
}
