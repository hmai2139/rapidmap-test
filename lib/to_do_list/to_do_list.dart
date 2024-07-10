import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidmap_test/to_do_list/forms/task_input_form.dart';
import 'package:rapidmap_test/to_do_list/providers/task_provider.dart';
import 'package:rapidmap_test/to_do_list/utils/datetime_utils.dart' as utils;
import 'package:rapidmap_test/to_do_list/models/task.dart';
import 'package:rapidmap_test/to_do_list/utils/datetime_utils.dart';
import 'package:rapidmap_test/to_do_list/utils/operation_result.dart';
import 'package:rapidmap_test/utils/snackbar_utils.dart';
import '../stylings/app_colours.dart';
import 'models/task_filter_options.dart';

/// A To-Do List app for RapidMap Developer Test Q1.
class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  /// Sort by ascending due date by default.
  bool _ascending = true;

  /// Default date range filter option is none.
  DateRangeFilterOption _currentDateRangeOption = DateRangeFilterOption.none;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  dynamic _buildCustomDateRangeText() {
    String text = '';
    switch (_currentDateRangeOption) {
      case DateRangeFilterOption.today:
        text = 'Showing tasks due today';
      case DateRangeFilterOption.thisMonth:
        text = 'Showing tasks due this month';
        break;
      case DateRangeFilterOption.custom:
        text = '''Showing tasks due from ${_startDate.day}/${_startDate.month}/${_startDate.year} to ${_endDate.day}/${_endDate.month}/${_endDate.year}''';
        break;
      case DateRangeFilterOption.none:
        break;
    }
    return text != ''
        ? Text(text,
            style: TextStyle(
                fontStyle: FontStyle.italic, color: AppColours.primary))
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Completed'),
                Tab(text: 'To-Do'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildSortOptions(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildDateRangeFilterOptions(),
                ),
              ],
            ),
            _buildCustomDateRangeText(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTaskList(TaskFilterOption.all, _currentDateRangeOption),
                  _buildTaskList(
                      TaskFilterOption.completed, _currentDateRangeOption),
                  _buildTaskList(
                      TaskFilterOption.uncompleted, _currentDateRangeOption),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColours.primary,
        onPressed: () => _inputTask(null),
        tooltip: 'Add a new task',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Display Tasks based on their completion status.
  FutureBuilder _buildTaskList(
      TaskFilterOption filterOption, DateRangeFilterOption rangeOption) {
    return FutureBuilder<void>(
      future: _fetchTasks(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(
                child: CircularProgressIndicator(
              color: AppColours.primary,
            ));

          case ConnectionState.done:
            final taskProvider = Provider.of<TaskProvider>(context);
            List<Task> tasks = taskProvider.tasks;
            tasks.sort((a, b) {
              if (_ascending) {
                return a.dueDate.compareTo(b.dueDate);
              } else {
                return b.dueDate.compareTo(a.dueDate);
              }
            });
            switch (filterOption) {
              case TaskFilterOption.all:
                break;
              case TaskFilterOption.completed:
                tasks = tasks.where((task) => task.completed > 0).toList();
                break;
              case TaskFilterOption.uncompleted:
                tasks = tasks.where((task) => task.completed == 0).toList();
                break;
            }
            switch (rangeOption) {
              case DateRangeFilterOption.none:
                break;
              case DateRangeFilterOption.today:
                tasks = tasks
                    .where((task) =>
                        utils.dateTimeFromEpoch(task.dueDate).day ==
                        DateTime.now().day)
                    .toList();
                break;
              case DateRangeFilterOption.thisMonth:
                tasks = tasks
                    .where((task) =>
                        utils.dateTimeFromEpoch(task.dueDate).month ==
                        DateTime.now().month)
                    .toList();
                break;
              case DateRangeFilterOption.custom:
                tasks = tasks
                    .where((task) =>
                        utils.dateTimeFromEpoch(task.dueDate).day >=
                            _startDate.day &&
                        utils.dateTimeFromEpoch(task.dueDate).day <=
                            _endDate.day &&
                        utils.dateTimeFromEpoch(task.dueDate).month >=
                            _startDate.month &&
                        utils.dateTimeFromEpoch(task.dueDate).month <=
                            _endDate.month)
                    .toList();
                break;
            }

            return tasks.isNotEmpty
                ? ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildTaskItem(tasks[index]),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No tasks found',
                        style: TextStyle(color: AppColours.subtext),
                      ),
                    ],
                  );
        }
      },
    );
  }

  /// Build a single Task widget.
  Widget _buildTaskItem(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => _inputTask(task),
      child: Card(
        child: ListTile(
          title: Text(task.title),
          leading: task.completed > 0
              ? GestureDetector(
                  onTap: () async {
                    final result =
                        await taskProvider.updateTaskCompletion(task, 0);
                    if (mounted) {
                      showSnackBar(
                          context,
                          result > 0
                              ? OperationResult.successUpdateUncompleted
                              : OperationResult.errorUpdateCompletionStatus);
                    }
                  },
                  child: Icon(
                    Icons.check_circle,
                    size: 25,
                    color: AppColours.accent,
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    final result =
                        await taskProvider.updateTaskCompletion(task, 1);
                    if (mounted) {
                      showSnackBar(
                          context,
                          result > 0
                              ? OperationResult.successUpdateCompleted
                              : OperationResult.errorUpdateCompletionStatus);
                    }
                  },
                  child: const Icon(Icons.check_circle_outline, size: 25),
                ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                style: TextStyle(color: AppColours.text, fontSize: 12),
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
                    style: TextStyle(color: AppColours.subtext, fontSize: 12),
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
                child: Icon(Icons.edit, size: 25, color: AppColours.primary),
              ),
              GestureDetector(
                onTap: () => _deleteTask(task.id!),
                child: const Icon(Icons.delete, size: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get Tasks from Provider.
  Future<void> _fetchTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.getTasks();
  }

  /// Insert/Update a Task.
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
            onPressed: () async {
              final result =
                  await Provider.of<TaskProvider>(context, listen: false)
                      .deleteTask(taskId);
              if (context.mounted) {
                showSnackBar(
                    context,
                    result > 0
                        ? OperationResult.successDelete
                        : OperationResult.errorDelete);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Build a dropdown menu to sort Task.
  DropdownButton _buildSortOptions() {
    TextStyle style = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColours.subtext,
    );
    return DropdownButton<bool>(
      value: _ascending,
      icon: Icon(Icons.sort, color: AppColours.subtext),
      onChanged: (bool? newValue) {
        if (newValue != null) {
          setState(() {
            _ascending = newValue;
          });
          Provider.of<TaskProvider>(context, listen: false)
              .sortTasksByDueDate(_ascending);
        }
      },
      items: [
        DropdownMenuItem<bool>(
          value: true,
          child: Text(
            'Earliest First',
            style: style,
          ),
        ),
        DropdownMenuItem<bool>(
          value: false,
          child: Text(
            'Latest First',
            style: style,
          ),
        ),
      ],
    );
  }

  /// Updates the date range filter option.
  void _updateDateRangeFilter(DateRangeFilterOption filterOption) {
    setState(() {
      _currentDateRangeOption = filterOption;
    });
  }

  /// Shows date range picker for custom date range filter option.
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked.start.isBefore(picked.end)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _updateDateRangeFilter(DateRangeFilterOption.custom);
    }
  }

  // Method to build the dropdown button for filtering by date range
  DropdownButton _buildDateRangeFilterOptions() {
    TextStyle style = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColours.subtext,
    );
    return DropdownButton<DateRangeFilterOption>(
      value: _currentDateRangeOption,
      icon: Icon(Icons.calendar_month, color: AppColours.subtext),
      onChanged: (DateRangeFilterOption? newValue) {
        if (newValue != null) {
          if (newValue == DateRangeFilterOption.custom) {
            _showDateRangePicker();
          } else {
            _updateDateRangeFilter(newValue);
          }
        }
      },
      items: [
        DropdownMenuItem<DateRangeFilterOption>(
          value: DateRangeFilterOption.today,
          child: Text(
            'Today',
            style: style,
          ),
        ),
        DropdownMenuItem<DateRangeFilterOption>(
          value: DateRangeFilterOption.thisMonth,
          child: Text(
            'This Month',
            style: style,
          ),
        ),
        DropdownMenuItem<DateRangeFilterOption>(
          value: DateRangeFilterOption.custom,
          child: Text(
            'Custom',
            style: style,
          ),
        ),
        DropdownMenuItem<DateRangeFilterOption>(
          value: DateRangeFilterOption.none,
          child: Text(
            'None',
            style: style,
          ),
        ),
      ],
    );
  }
}
