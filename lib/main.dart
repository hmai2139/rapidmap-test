import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidmap_test/sudoku/sudoku.dart';
import 'package:rapidmap_test/to_do_list/providers/task_provider.dart';
import 'package:rapidmap_test/to_do_list/to_do_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) =>
              setState(() => _currentPageIndex = index),
          indicatorColor: Colors.deepPurpleAccent,
          selectedIndex: _currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.task_outlined),
              label: 'To-Do List',
            ),
            NavigationDestination(
              icon: Badge(child: Icon(Icons.border_all_rounded)),
              label: 'Sudoku',
            ),
          ],
        ),
        body: Center(
            child: [
          /// To-Do List page.
          const ToDoList(),

          /// Sudoku page.
          const Sudoku()
        ][_currentPageIndex]));
  }
}
