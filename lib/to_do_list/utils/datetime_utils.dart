import 'package:intl/intl.dart';

/// DateTime helpers methods.

/// Format a UNIX Timestamp to a `dd-MM-yyyy` date string.
String formatDate(int timestamp) => DateFormat("dd-MM-yyyy")
    .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

/// Convert `dd-MM-yyyy` date string to a UNIX Timestamp.
int convertDateToEpoch(String dateString) =>
    DateFormat('dd-MM-yyyy').parse(dateString).millisecondsSinceEpoch;

/// Convert a UNIX Timestamp to DateTime object.
DateTime dateTimeFromEpoch(int timestamp) =>
    DateTime.fromMillisecondsSinceEpoch(timestamp);
