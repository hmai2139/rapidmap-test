/// Task data model.
class Task {
  final int? id;
  final String title;
  final String description;
  final int dueDate;
  final int completed;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.completed = 0,
  });

  /// Convert a Task into a Map.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'completed': completed,
    };
  }

  /// Creates a String representation of a given Task.
  @override
  String toString() {
    return '{id: $id,title: $title,description: $description,dueDate: $dueDate,completed: $completed}';
  }
}
