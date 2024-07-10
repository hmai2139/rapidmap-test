/// Some utility functions.
library;

/// Deep-copy a List<List<int>>.
List<List<int>> deepCopy(List<List<int>> source) {
  return source.map((e) => e.toList()).toList();
}