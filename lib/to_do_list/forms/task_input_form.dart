import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidmap_test/to_do_list/models/database.dart';
import 'package:rapidmap_test/to_do_list/models/task.dart';
import 'package:rapidmap_test/to_do_list/providers/task_provider.dart';
import 'package:rapidmap_test/to_do_list/utils/snackbar_utils.dart';
import '../../stylings/app_colours.dart';
import '../utils/datetime_utils.dart' as utils;
import 'package:flutter/services.dart';

/// Form for user to add/update a [Task].

class TaskInputForm extends StatefulWidget {
  final Task? task;

  const TaskInputForm({super.key, this.task});

  @override
  State<TaskInputForm> createState() => _TaskInputFormState();
}

class _TaskInputFormState extends State<TaskInputForm> {
  /// Create a global key that uniquely identifies the Form widget
  /// and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.task != null) {
      Task task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _dueDateController.text = utils.formatDate(task.dueDate);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextFormField(
            controller: _titleController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(DatabaseHelper.maxTitleLength)
            ],
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: '${DatabaseHelper.maxTitleLength} characters or fewer',
              labelStyle: const TextStyle(fontSize: 15),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            validator: _validateTitle,
          ),
          TextFormField(
            controller: _descriptionController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  DatabaseHelper.maxDescriptionLength)
            ],
            decoration: InputDecoration(
              labelText: 'Description',
              hintText:
                  '${DatabaseHelper.maxDescriptionLength} characters or fewer',
              labelStyle: const TextStyle(fontSize: 15),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: _validateDescription,
          ),
          TextFormField(
            controller: _dueDateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Due Date',
              labelStyle: TextStyle(fontSize: 15),
              hintText: 'Select due date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(context),
            validator: _validateDate,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.task?.id != null
                    ? FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () => _deleteTask(widget.task!.id!),
                        child: const Text('Delete'),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColours.primary),
                  onPressed: () async {
                    /// Validate the form before submission.
                    if (_formKey.currentState!.validate()) {
                      final taskProvider =
                          Provider.of<TaskProvider>(context, listen: false);

                      Task newTask = Task(
                        id: widget.task?.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        dueDate:
                            utils.convertDateToEpoch(_dueDateController.text),
                        completed:
                            widget.task != null ? widget.task!.completed : 0,
                      );

                      /// If Task's data has been passed, update Task.
                      if (widget.task != null) {
                        final updateResult =
                            await taskProvider.updateTask(newTask);
                        if (context.mounted) {
                          showSnackBar(context, 'Task updated');
                          Navigator.of(context).pop();
                        }
                      }

                      /// Otherwise add Task to the database.
                      else {
                        final addResult =
                            await taskProvider.insertTask(newTask);
                        if (context.mounted) {
                          showSnackBar(context, 'Task added');
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  },
                  child: Text(widget.task?.id != null ? 'Update' : 'Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),

      /// Users would most certainly be dead before then.
      lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDateController.text =
            utils.formatDate(selectedDate.millisecondsSinceEpoch);
      });
    }
  }

  /// Validate Task's title.
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title for this task';
    } else if (value.length > DatabaseHelper.maxTitleLength) {
      return '''Titles must not be more than
                    ${DatabaseHelper.maxTitleLength}-character long''';
    }
    return null;
  }

  /// Validate Task's description.
  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description for this task';
    } else if (value.length > DatabaseHelper.maxDescriptionLength) {
      return '''Descriptions must not be more than
                    ${DatabaseHelper.maxDescriptionLength}-character long''';
    }
    return null;
  }

  /// Validate Task's due date.
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a due date';
    }
    return null;
  }

  /// Show Task deletion confirmation dialog.
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
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
