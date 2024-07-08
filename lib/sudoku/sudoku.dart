import 'package:flutter/material.dart';

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

  /// The initial puzzle.
  final List<List<int>> _puzzle = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];

  /// Whether a puzzle is being solved;
  bool isSolving = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /// Game board.
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 1)),
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
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
                  onPressed: () {},
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {},
                  child: const Text('Solve'),
                )
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
              color: isSolving ? Colors.blueAccent : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a number picker of 1 to 9.
  /// Sets the number of the (x, y) tile to the picked number.
  void _tileOnTap(int x, int y) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width * .7,
          height: MediaQuery.of(context).size.width * .7,
          child: GridView.count(
            crossAxisCount: 3,
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
