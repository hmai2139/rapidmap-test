import 'package:flutter/material.dart';

/// Shows a Snackbar with [text].
void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    backgroundColor: Colors.deepPurple,
    duration: const Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
