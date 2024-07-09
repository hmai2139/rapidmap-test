import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:rapidmap_test/to_do_list/models/task.dart';
import 'package:sqflite/sqflite.dart';

String tableName = "tasks";

class DatabaseHelper {
  static Database? _database;

  /// Max lengths of title and description, in # characters.
  static int maxTitleLength = 30;
  static int maxDescriptionLength = 100;

  /// Ensures only 1 instance of DatabaseHelper is instantiated.
  static final DatabaseHelper helper = DatabaseHelper._secretConstructor();
  DatabaseHelper._secretConstructor();

  Future<Database> _createDatabase() async {
    /// Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();

    return await openDatabase(
      /// Set the path to the database.
      join(await getDatabasesPath(), 'task_database.db'),

      /// When the database is first created, create a table to store tasks.
      onCreate: (db, version) {
        /// Run the CREATE TABLE statement on the database.
        return db.execute(
          '''CREATE TABLE tasks (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL DEFAULT Task ,
            description TEXT NOT NULL DEFAULT A new task,
            dueDate INTEGER NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0
            CHECK (
              length(title) <= $maxTitleLength)
              length(description) <= $maxDescriptionLength)
            )
          )''',
        );
      },

      /// Set the version. This executes the onCreate function and provides a
      /// path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  /// Get a reference to the database.
  Future<Database> get dataBase async {
    if (_database != null) return _database!;

    _database = await _createDatabase();
    return _database!;
  }

  /// Inserts [Task] into the database.
  Future<void> insertTask(Task task) async {
    /// Get a reference to the database.
    final db = await helper.dataBase;

    /// Inserts the Task into the correct table.
    /// Replaces duplicate with new data.
    await db.insert(
      tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ).then((result) {
      print("insert result:$result");
    });
  }

  /// Retrieves all the [Task] objects from the database.
  Future<List<Task>> getTasks() async {
    /// Get a reference to the database.
    final db = await helper.dataBase;

    /// Query the table for all the tasks.
    final List<Map<String, Object?>> taskMaps = await db.query(tableName);

    /// Convert the list of each task's fields into a list of `Task` objects.
    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'description': description as String,
            'dueDate': dueDate as int,
            'completed': completed as int,
          } in taskMaps)
        Task(
            id: id,
            title: title,
            description: description,
            dueDate: dueDate,
            completed: completed),
    ];
  }

  /// Update a [Task] in the database.
  Future<void> updateTask(Task task) async {
    /// Get a reference to the database.
    final db = await helper.dataBase;

    /// Update the given Task.
    await db.update(
      tableName,
      task.toMap(),

      /// Ensure that the Task has a matching id.
      where: 'id = ?',

      /// Pass the Task's id as a whereArg to prevent SQL injection.
      whereArgs: [task.id],

    ).then((result) {
      print("update result:$result");
    });
  }

  /// Update a [Task]'s completion status'.
  Future<void> updateCompletionStatus(Task task, int status) async {
    await updateTask(
      Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        completed: status,
      ),
    );
  }

  /// Delete a [Task] from the database.
  Future<void> deleteTask(int id) async {
    /// Get a reference to the database.
    final db = await helper.dataBase;

    /// Remove the Task from the database.
    await db.delete(
      tableName,

      /// Use a `where` clause to delete a specific Task.
      where: 'id = ?',

      /// Pass the Task's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
