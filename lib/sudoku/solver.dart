/// Backtracking algorithm implementation to solve a valid 9x9 Sudoku puzzle.
library;

/// Assume all puzzles are 9x9.
int N = 9;

/// Checks if [num] can be placed onto the tile at puzzle[row][col];
bool isValid(List<List<int>> puzzle, int row, int col, int num) {
  /// Checks for duplicate within the same row and the same column.
  for (var i = 0; i < N; i++) {
    if (puzzle[row][i] == num || puzzle[i][col] == num) {
      return false;
    }
  }

  /// Checks for duplicate within the same region.
  int startRow = row - row % 3, startCol = col - col % 3;
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      if (puzzle[i + startRow][j + startCol] == num) {
        return false;
      }
    }
  }
  return true;
}

/// Check if a Sudoku board is valid.
bool isValidSudoku(List<List<int>> puzzle) {
  // Helper function to check if a list has duplicates excluding zeros
  bool hasDuplicates(List<int> list) {
    List<int> filteredList = list.where((int num) => num != 0).toList();
    return filteredList.length != filteredList.toSet().length;
  }

  // Check each row
  for (var row in puzzle) {
    if (hasDuplicates(row)) return false;
  }

  // Check each column
  for (var col = 0; col < 9; col++) {
    List<int> column = [];
    for (var row = 0; row < 9; row++) {
      column.add(puzzle[row][col]);
    }
    if (hasDuplicates(column)) return false;
  }

  // Check each 3x3 subgrid
  for (var row = 0; row < 9; row += 3) {
    for (var col = 0; col < 9; col += 3) {
      List<int> subgrid = [];
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          subgrid.add(puzzle[row + r][col + c]);
        }
      }
      if (hasDuplicates(subgrid)) return false;
    }
  }

  return true;
}

class Solution {
  final List<List<int>> puzzle;
  final bool solvable;

  Solution(this.puzzle, this.solvable);
}

/// Solves [puzzle] by backtracking via recursion.
Solution solve(List<List<int>> puzzle, int row, int col) {
  /// Reached the end of the puzzle, return the solution.
  if (row == N - 1 && col == N) {
    return Solution(puzzle, true);
  }

  /// Reached the end of the current row, move on to the next row.
  if (col == N) {
    row++;
    col = 0;
  }

  /// The tile is already filled, move on to the next tile in the same row.
  if (puzzle[row][col] > 0) {
    return solve(puzzle, row, col + 1);
  }

  /// Backtracking starts.
  for (int num = 1; num <= N; num++) {
    /// Check if a given number from 1 to 9 is valid for the current tile.
    if (isValid(puzzle, row, col, num)) {
      puzzle[row][col] = num;

      /// [num] is valid for the current tile, move on to the next tile.
      if (solve(puzzle, row, col + 1).solvable == true) {
        return Solution(puzzle, true);
      }
    }

    /// Found a tile in which none of the numbers from 1 to 9 can be placed.
    /// Removes [num] from the current tile and move to [num+1].
    puzzle[row][col] = 0;
  }

  /// No solutions found.
  return Solution(puzzle, false);
}
