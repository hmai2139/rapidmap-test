import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rapidmap_test/sudoku/utils/sudoku_solver.dart' as solver;

import '../../stylings/app_colours.dart';

/// Methods to generate puzzle puzzles for testing.
/// The random generator methods are credited to ChatGPT.

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
  List<List<int>> puzzle = List.generate(9, (_) => List.generate(9, (_) => 0));
  fillDiagonal(puzzle);
  fillRemaining(puzzle, 0, 3);
  removeDigits(puzzle);
  return puzzle;
}

/// Fills the diagonal 3x3 boxes of the Sudoku grid.
/// Ensures that the diagonal boxes are valid subgrids.
void fillDiagonal(List<List<int>> puzzle) {
  for (var i = 0; i < 9; i += 3) {
    fillBox(puzzle, i, i);
  }
}

/// Fills a 3x3 box with random numbers 1 to 9.
/// Ensures that the box contains all unique numbers.
void fillBox(List<List<int>> puzzle, int row, int col) {
  Random random = Random();
  List<int> numbers = List.generate(9, (index) => index + 1)..shuffle(random);
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      puzzle[row + i][col + j] = numbers[i * 3 + j];
    }
  }
}

/// Fills the remaining cells of the Sudoku grid.
/// Ensures that the grid remains valid and follows Sudoku rules.
bool fillRemaining(List<List<int>> puzzle, int i, int j) {
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
    if (solver.isValid(puzzle, i, j, num)) {
      puzzle[i][j] = num;
      if (fillRemaining(puzzle, i, j + 1)) {
        return true;
      }
      puzzle[i][j] = 0;
    }
  }
  return false;
}

/// Removes a specified number of digits from the Sudoku grid.
/// Creates an unsolved puzzle by setting cells to zero.
void removeDigits(List<List<int>> puzzle) {
  Random random = Random();

  /// Removes at least 40, configurable;
  int minRemove = 40;

  /// Minimum clues # is 17, so can remove (81 - 17 = 64) at most.
  int maxRemove = 64;

  int count = random.nextInt(maxRemove - minRemove) + minRemove;

  while (count != 0) {
    int cellId = random.nextInt(81);
    int i = cellId ~/ 9;
    int j = cellId % 9;
    if (puzzle[i][j] != 0) {
      count--;
      puzzle[i][j] = 0;
    }
  }
}

/// Prints the Sudoku grid to the console.
/// Displays the 9x9 grid in a readable format.
void printSudoku(List<List<int>> puzzle) {
  for (var row in puzzle) {
    print(row);
  }
}

/// Generates an empty 9x9 Sudoku puzzle.
List<List<int>> generateEmptySudoku() =>
    List.generate(9, (_) => List.generate(9, (_) => 0));

/// Generate a matching 2D array of [Color] based on the current puzzle.
List<List<Color>> generateColours(List<List<int>> puzzle) {
  return List.generate(9, (row) {
    return List.generate(9, (col) {
      return puzzle[row][col] > 0 ? AppColours.text : AppColours.primary;
    });
  });
}

