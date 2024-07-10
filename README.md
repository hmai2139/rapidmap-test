# rapidmap_test

Solutions to RapidMap developer test
1. **To-Do List**: A To-Do List application.
2. **Sudoku**: A Sudoku puzzle game.
3. **Email System Automation Solution**: A PDF outlining the steps to set-up an email system
   
## Installation
1. **Install Flutter and SQLite**
- [Flutter](https://docs.flutter.dev/get-started/codelab)
- [SQLite](https://docs.flutter.dev/cookbook)
2. **Clone the repository:**

   ```bash
   git clone https://github.com/hmai2139/rapidmap-test.git
   ```
   OR
   ```bash
   git clone git@github.com:hmai2139/rapidmap-test.git
   ```
3. **Install dependencies**
   ```bash
   flutter pub get
   ```
4. **Run the application**
   ```bash
   flutter run
   ```
## To-Do List

A task management application that allows users to create, view, edit, and delete tasks. Tasks are stored in a local SQLite database.

### Features

- Create new tasks with a title, description, and due date.
- Sort tasks by due date.
- Filter tasks by completion status and date range.
- Edit or delete tasks.

### Usage
- Use the "+" button to add a new task.
- View tasks by completion status via top tab bar.
- Tap on a task or the pen button to view/edit/delete a task.
- Tap on the garbage bin icon to delete a task.

### Testing
Unit tests for database operations are available:
```bash
flutter test lib\to_do_list\test\database_helper_test.dart
```

## Sudoku

A 9x9 Sudoku game that allows users to input their own puzzles and solve them either manually or automatically using [backtracking algorithm](https://en.wikipedia.org/wiki/Sudoku_solving_algorithms#Backtracking).

### Features

- Generate random Sudoku puzzles.
- Input custom Sudoku puzzles.
- Automatically solve puzzles using a backtracking algorithm.
- Automatically validate puzzles on input.
- Feedbacks when solving puzzles.

### Usage
- Use the "Randomise" button to generate a new Sudoku puzzle.
- Use the "Clear" button to clear the current puzzle.
- Tap on a tile to set its value.
- Use the "Solve" button to solve the puzzle automatically.

