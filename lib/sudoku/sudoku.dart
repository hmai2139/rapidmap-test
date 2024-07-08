import 'package:flutter/material.dart';
import 'package:rapidmap_test/sudoku/generator.dart' as generator;

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

  void _generate() {
    setState(() {
      _puzzle = generator.generateSudoku();
    });
  }

  void _initialise() {
    _puzzle = generator.generateEmptySudoku();
    _colours = generator.generateColours();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  onPressed: () {},
                  child: const Text('Solve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A single tile on the puzzle board.
  ///
  /// The number will be blue if [isInitial] is true, and black otherwise.
  Widget _buildTile(BuildContext context, int index) {
    /// Calculates coordinates (x, y) from [index].
    int x = (index / N).floor();
    int y = (index % N);

    int val = _puzzle[x][y];
    return GestureDetector(
      onTap: () => _tileOnTap(x, y),
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
              color: _colours[x][y],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a number picker of 1 to 9.
  /// Sets the number of the (x, y) tile to the picked number.
  void _tileOnTap(int x, int y) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54, width: 1),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 2,
            children: [for (var i = 1; i < 10; i++) i]
                .map(
                  (val) => OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      side: const BorderSide(width: 0.5, color: Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        _puzzle[x][y] = val;
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
      ),
    );
  }
}
