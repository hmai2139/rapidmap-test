import 'package:flutter/material.dart';

import '../stylings/app_colours.dart';

/// Shows a Snackbar with [text].
void showSnackBar(BuildContext context, String text,
    {Duration duration = const Duration(seconds: 1)}) {
  final snackBar = SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    backgroundColor: AppColours.accent,
    duration: duration,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
