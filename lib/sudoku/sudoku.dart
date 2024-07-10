import 'package:flutter/material.dart';
import 'package:rapidmap_test/utils/list_utils.dart';
import 'package:rapidmap_test/sudoku/helpers/sudoku_generator.dart' as generator;
import 'package:rapidmap_test/sudoku/helpers/sudoku_solver.dart' as solver;

import '../stylings/app_colours.dart';
import '../utils/snackbar_utils.dart';

/// A 9x9 Sudoku game for RapidMap Developer Test Q2.
/// User can input their own puzzles.
/// Can be solved manually or automatically using a backtracking algorithm.
class Sudoku extends StatefulWidget {
  const Sudoku({super.key});

  @override
  State<Sudoku> createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  /// Assume all puzzles are NxN.
  int N = 9;

  /// Default puzzle board.
  List<List<int>> _puzzle = generator.generateEmptySudoku();

  /// Colour array to differentiate numbers from input and solution.
  List<List<Color>> _colours =
      generator.generateColours(generator.generateEmptySudoku());

  /// Whether puzzle is invalid.
  bool _isValid = false;

  /// Generate a Sudoku puzzle.
  void _generate() {
    setState(() {
      _puzzle = generator.generateSudoku();
      _colours = generator.generateColours(_puzzle);
      _isValid = true;
    });
  }

  /// Initialise an empty board.
  void _initialise() {
    _puzzle = generator.generateEmptySudoku();
    _colours = generator.generateColours(_puzzle);
    _isValid = true;
  }

  /// Attempt to solve the puzzle.
  dynamic _solvePuzzle() {
    final List<List<int>> unsolved = deepCopy(_puzzle);
    solver.Solution solution = solver.solve(_puzzle, 0, 0);

    /// Display the solution if found.
    if (solution.solvable) {
      setState(() {
        _colours = generator.generateColours(unsolved);
      });
      showSnackBar(context, 'Puzzle solved');
    }

    /// Otherwise display an error message.
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "No solutions found",
              style: TextStyle(color: AppColours.subtext),
            ),
            content: Text(
              "The puzzle may be invalid or insufficient clues were provided.",
              style: TextStyle(color: AppColours.subtext),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Bummer :(",
                  style: TextStyle(color: AppColours.primary),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              /// Game board.
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColours.subtext, width: 1),
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: N, childAspectRatio: 1),
                    itemBuilder: _buildTile,
                    itemCount: N * N,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Button rows.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColours.subtext),
                    onPressed: () => setState(() {
                      _initialise();
                    }),
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColours.primary),
                    onPressed: _generate,
                    child: const Text('Randomise'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColours.accent),
                    onPressed: _isValid
                        ? _solvePuzzle
                        : () => showSnackBar(
                            context, 'Invalid puzzle. Please check your inputs',
                            duration: const Duration(seconds: 2),),
                    child: const Text('Solve'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A single tile on the puzzle board.
  Widget _buildTile(BuildContext context, int index) {
    /// Calculates coordinates (x, col) from [index].
    int row = (index / N).floor();
    int col = (index % N);

    int val = _puzzle[row][col];
    return GestureDetector(
      onTap: () => _tileOnTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColours.subtext,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            val > 0 ? val.toString() : " ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: _colours[row][col],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a number picker of 1 to 9.
  /// Sets the number of the (row, col) tile to the picked number.
  void _tileOnTap(int row, int col) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          childAspectRatio: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 5,
          children: [for (var i = 0; i < 10; i++) i]
              .map(
                (val) => OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _puzzle[row][col] = val;
                      _colours[row][col] = AppColours.text;
                      _isValid = solver.isValidSudoku(_puzzle);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    val.toString(),
                    style: TextStyle(
                        fontSize: 20,
                        color: AppColours.text,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
