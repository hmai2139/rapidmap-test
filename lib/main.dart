import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidmap_test/stylings/app_colours.dart';
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

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> pages = ['To-Do List', 'Sudoku'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColours.primary,
        title: Text(
          pages[_currentPageIndex],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentPageIndex = index);
          },
          children: const <Widget>[
            ToDoList(),
            Sudoku(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        selectedItemColor: AppColours.primary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              label: 'To-Do List', icon: Icon(Icons.task_outlined)),
          BottomNavigationBarItem(
            label: ('Sudoku'),
            icon: Icon(Icons.border_all_rounded),
            backgroundColor: Colors.lightBlue,
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;

      /// Animate navigation between pages.
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }
}
