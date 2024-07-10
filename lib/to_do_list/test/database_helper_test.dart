import 'package:path/path.dart';
import 'package:rapidmap_test/to_do_list/models/task.dart';
import 'package:rapidmap_test/to_do_list/models/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String aVeryLongTitle = '''This is a very
       longgggggggggggggggggggggggggggggggggggggggggggggggg
       gggggggggggggggggggggggggggggggggggggggggggggggggggg
       ggggggggggggggggggggggggg title''';

const String aVeryLongDescription = '''This is a very
      longgggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      gggggggggggggggggggggggggggggggggggggggggggggggggggg
      description''';

void main() {
  /// Initialise sqflite for tests.
  sqfliteFfiInit();

  /// Set the factory for sqflite to use ffi for testing.
  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
  });

  DatabaseHelper databaseHelper = DatabaseHelper.helper;

  group('DatabaseHelper Tests', () {
    setUp(() async {
      /// Re-initialise the database before each test.
      String path = join(await getDatabasesPath(), 'task_database.db');
      await databaseFactory.deleteDatabase(path);
      databaseHelper = DatabaseHelper.helper;
    });

    /// Close the database after each test to prevent errors.
    tearDown(() async {
      await databaseHelper.closeDatabase();
    });

    /// Fetch test(s).
    test('Fetch test', () async {
      databaseHelper = DatabaseHelper.helper;

      Task task1 = Task(
        title: 'Test task 1',
        description: 'This is test task 1',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      Task task2 = Task(
        title: 'Test task 2',
        description: 'This is test task 2',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task1);
      await databaseHelper.insertTask(task2);

      List<Task> tasks = await databaseHelper.getTasks();
      expect(tasks.length, 2);
    });

    /// Insert test(s).
    test('Insert valid Tasks', () async {
      databaseHelper = DatabaseHelper.helper;

      Task task = Task(
        title: 'Test task',
        description: 'This is a test task',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task);

      List<Task> tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test task');
    });

    test('Insert a Task with title and description longer than limit',
        () async {
      Task invalidTask = Task(
        title: aVeryLongTitle,
        description: aVeryLongDescription,
        dueDate: DateTime.now().millisecondsSinceEpoch,
      );

      final result = await databaseHelper.insertTask(invalidTask);
      List<Task> tasks = await databaseHelper.getTasks();

      /// Should fail.
      expect(result, 0);
      expect(tasks.isEmpty, true);
    });

    /// Update test(s).
    test('Update a Task with valid input', () async {
      databaseHelper = DatabaseHelper.helper;

      Task task = Task(
        title: 'To-be-updated task',
        description: 'This is a to-be-updated task',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task);

      List<Task> tasks = await databaseHelper.getTasks();
      Task firstTask = tasks.first;

      Task updatedTask = Task(
        id: firstTask.id,
        title: 'Updated task',
        description: 'This is an updated task',
        dueDate: firstTask.dueDate,
        completed: 0,
      );

      await databaseHelper.updateTask(updatedTask);

      tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Updated task');
      expect(tasks.first.description, 'This is an updated task');
    });

    test('Update a Task with title and description longer than limit',
        () async {
      databaseHelper = DatabaseHelper.helper;

      Task task = Task(
        title: 'To-be-updated task',
        description: 'This is a to-be-updated task',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task);

      List<Task> tasks = await databaseHelper.getTasks();
      Task firstTask = tasks.first;

      Task updatedTask = Task(
        id: firstTask.id,
        title: aVeryLongTitle,
        description: aVeryLongDescription,
        dueDate: firstTask.dueDate,
        completed: 0,
      );

      final result = await databaseHelper.updateTask(updatedTask);

      tasks = await databaseHelper.getTasks();

      /// Should fail.
      expect(result, 0);
      expect(tasks.first.title, 'To-be-updated task');
      expect(tasks.first.description, 'This is a to-be-updated task');
    });

    /// Update completion status test(s).
    test('Mark a Task as completed test', () async {
      databaseHelper = DatabaseHelper.helper;

      Task task = Task(
        title: 'Uncompleted task',
        description: 'This is an uncompleted task',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task);

      List<Task> tasks = await databaseHelper.getTasks();
      Task firstTask = tasks.first;

      Task updatedTask = Task(
        id: firstTask.id,
        title: 'Completed task',
        description: 'This is now a completed task',
        dueDate: firstTask.dueDate,
        completed: 1,
      );

      await databaseHelper.updateTask(updatedTask);

      tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Completed task');
      expect(tasks.first.description, 'This is now a completed task');
      expect(tasks.first.completed, 1);
    });

    test('Mark a Task as uncompleted test', () async {
      databaseHelper = DatabaseHelper.helper;

      Task task = Task(
        title: 'Completed task',
        description: 'This is a completed task',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task);

      List<Task> tasks = await databaseHelper.getTasks();
      Task firstTask = tasks.first;

      Task updatedTask = Task(
        id: firstTask.id,
        title: 'Uncompleted task',
        description: 'This is now an uncompleted task',
        dueDate: firstTask.dueDate,
        completed: 0,
      );

      await databaseHelper.updateTask(updatedTask);

      tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Uncompleted task');
      expect(tasks.first.description, 'This is now an uncompleted task');
      expect(tasks.first.completed, 0);
    });

    /// Delete test(s).
    test('Delete an existing task test', () async {
      databaseHelper = DatabaseHelper.helper;

      Task task = Task(
        title: 'Test task',
        description: 'This is a test task',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        completed: 0,
      );

      await databaseHelper.insertTask(task);

      List<Task> tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);

      await databaseHelper.deleteTask(tasks.first.id!);

      tasks = await databaseHelper.getTasks();
      expect(tasks.isEmpty, true);
    });
  });

  test('Delete task with a negative ID', () async {
    int invalidId = -1;

    final result = await databaseHelper.deleteTask(invalidId);

    /// Should fail.
    expect(result, 0);
  });
}
