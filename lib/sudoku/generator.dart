import 'dart:math';

/// Generate random sudoku puzzles for testing.
/// Credit: ChatGPT.

void main() {
  List<List<List<int>>> puzzles = generateSudokuPuzzles(50);
  for (var i = 0; i < puzzles.length; i++) {
    print('Puzzle ${i + 1}:');
    printSudoku(puzzles[i]);
    print('');
  }
}

/// Generates a specified number of unsolved Sudoku puzzles.
/// Each puzzle is a 9x9 grid with some numbers removed.
List<List<List<int>>> generateSudokuPuzzles(int count) {
  List<List<List<int>>> puzzles = [];
  for (var i = 0; i < count; i++) {
    List<List<int>> puzzle = generateSudoku();
    puzzles.add(puzzle);
  }
  return puzzles;
}

/// Generates a single unsolved Sudoku puzzle.
/// The puzzle is a 9x9 grid with some numbers removed.
List<List<int>> generateSudoku() {
  List<List<int>> sudoku = List.generate(9, (_) => List.generate(9, (_) => 0));
  fillDiagonal(sudoku);
  fillRemaining(sudoku, 0, 3);
  removeDigits(sudoku);
  return sudoku;
}

/// Fills the diagonal 3x3 boxes of the Sudoku grid.
/// Ensures that the diagonal boxes are valid subgrids.
void fillDiagonal(List<List<int>> sudoku) {
  for (var i = 0; i < 9; i += 3) {
    fillBox(sudoku, i, i);
  }
}

/// Fills a 3x3 box with random numbers 1 to 9.
/// Ensures that the box contains all unique numbers.
void fillBox(List<List<int>> sudoku, int row, int col) {
  Random random = Random();
  List<int> numbers = List.generate(9, (index) => index + 1)..shuffle(random);
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      sudoku[row + i][col + j] = numbers[i * 3 + j];
    }
  }
}

/// Checks if a number can be placed at a specific position in the grid.
/// Ensures that the number does not violate Sudoku rules.
bool isSafe(List<List<int>> sudoku, int row, int col, int num) {
  for (var x = 0; x < 9; x++) {
    if (sudoku[row][x] == num || sudoku[x][col] == num) {
      return false;
    }
  }
  int startRow = row - row % 3, startCol = col - col % 3;
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      if (sudoku[i + startRow][j + startCol] == num) {
        return false;
      }
    }
  }
  return true;
}

/// Fills the remaining cells of the Sudoku grid.
/// Ensures that the grid remains valid and follows Sudoku rules.
bool fillRemaining(List<List<int>> sudoku, int i, int j) {
  if (j >= 9 && i < 8) {
    i += 1;
    j = 0;
  }
  if (i >= 9 && j >= 9) {
    return true;
  }
  if (i < 3) {
    if (j < 3) {
      j = 3;
    }
  } else if (i < 9 - 3) {
    if (j == (i ~/ 3) * 3) {
      j += 3;
    }
  } else {
    if (j == 9 - 3) {
      i += 1;
      j = 0;
      if (i >= 9) {
        return true;
      }
    }
  }
  for (var num = 1; num <= 9; num++) {
    if (isSafe(sudoku, i, j, num)) {
      sudoku[i][j] = num;
      if (fillRemaining(sudoku, i, j + 1)) {
        return true;
      }
      sudoku[i][j] = 0;
    }
  }
  return false;
}

/// Removes a specified number of digits from the Sudoku grid.
/// Creates an unsolved puzzle by setting cells to zero.
void removeDigits(List<List<int>> sudoku) {
  Random random = Random();
  int count = 40;
  while (count != 0) {
    int cellId = random.nextInt(81);
    int i = cellId ~/ 9;
    int j = cellId % 9;
    if (sudoku[i][j] != 0) {
      count--;
      sudoku[i][j] = 0;
    }
  }
}

/// Prints the Sudoku grid to the console.
/// Displays the 9x9 grid in a readable format.
void printSudoku(List<List<int>> sudoku) {
  for (var row in sudoku) {
    print(row);
  }
}