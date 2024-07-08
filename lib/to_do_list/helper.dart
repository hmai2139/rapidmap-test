import 'package:intl/intl.dart';

/// Some helpers function

String formatDate(int millisecondsSinceEpoch) {
  return DateFormat("dd-MM-yyyy")
      .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
}
