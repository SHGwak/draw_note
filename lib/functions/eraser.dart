import 'dart:ui';

List<List<Offset>> checkForOverlappingStrokes(
    Offset eraserPos, List<List<Offset>> strokes,
    {double sqrSize = 10}) {
  final List<List<Offset>> overlapping = [];
  for (int i = 0; i < strokes.length; i++) {
    final List<Offset> stroke = strokes[i];
    if (_shouldStrokeBeErased(eraserPos, stroke, sqrSize)) {
      overlapping.add(stroke);
      //_erased.add(stroke);
    }
  }
  return overlapping;
}

bool _shouldStrokeBeErased(
    Offset eraserPos, List<Offset> stroke, double sqrSize) {
  /// skip checking every few vertices for performance
  final int verticesToSkip;
  if (stroke.length < 100) {
    verticesToSkip = 0;
  } else if (stroke.length < 1000) {
    verticesToSkip = 1;
  } else {
    verticesToSkip = 2;
  }

  for (int i = 0; i < stroke.length; i += verticesToSkip + 1) {
    final Offset strokeVertex = stroke[i];
    if (sqrDistanceBetween(strokeVertex, eraserPos) <= sqrSize) return true;
  }
  return false;
}

double square(double x) => x * x;

double sqrDistanceBetween(Offset p1, Offset p2) =>
    square(p1.dx - p2.dx) + square(p1.dy - p2.dy);
