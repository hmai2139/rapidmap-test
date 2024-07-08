import 'package:flutter/material.dart';
import 'package:rapidmap_test/sudoku/generator.dart' as generator;
import 'package:rapidmap_test/sudoku/solver.dart' as solver;

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

  List<List<int>> _puzzle = generator.generateEmptySudoku();

  /// Colour array to differentiate numbers from input and solution.
  List<List<Color>> _colours = generator.generateColours();

  /// Whether puzzle is invalid.
  bool _isValid = false;

  void _generate() {
    setState(() {
      _puzzle = generator.generateSudoku();
      _isValid = true;
    });
  }

  void _initialise() {
    _puzzle = generator.generateEmptySudoku();
    _colours = generator.generateColours();
  }

  _solvePuzzle() {
    solver.Solution solution = solver.solve(_puzzle, 0, 0);
    if (solution.solvable) {
      setState(() {
        _colours = List.generate(
            9,
            (row) => List.generate(
                9,
                (col) =>
                    _puzzle[row][col] > 0 ? Colors.black : Colors.blueAccent));
        _puzzle = solution.puzzle;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "No solutions found",
              style: TextStyle(color: Colors.blueAccent),
            ),
            content: const Text(
                "The puzzle may be invalid or insufficient clues were provided."),
            actions: [
              TextButton(
                child: const Text("Bummer :(",
                    style: TextStyle(color: Colors.blueAccent)),
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
                    border: Border.all(color: Colors.black54, width: 1),
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
                    style:
                        FilledButton.styleFrom(foregroundColor: Colors.black54),
                    onPressed: () => setState(() {
                      _initialise();
                    }),
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    onPressed: _generate,
                    child: const Text('Randomise'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    onPressed: _isValid ? _solvePuzzle : null,
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
  ///
  /// The number will be blue if [isInitial] is true, and black otherwise.
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
            color: Colors.black54,
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
                      _isValid = solver.isValidSudoku(_puzzle);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    val.toString(),
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blueAccent,
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
