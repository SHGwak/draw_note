import 'dart:ui';

Path getPath(List<Offset> polygonLines) {
  Path polygonPath = Path();
  if (polygonLines.length == 0) {
    return polygonPath;
  }
  polygonPath.moveTo(polygonLines[0].dx, polygonLines[0].dy);
  for (int i = 1; i < polygonLines.length; i++) {
    polygonPath.lineTo(polygonLines[i].dx, polygonLines[i].dy);
  }
  return polygonPath;
}

double polygonPercentInside(Path selection, List<Offset> polygon) {
  int pointsInside = 0;
  for (Offset point in polygon) {
    if (selection.contains(point)) {
      pointsInside++;
    }
  }
  return pointsInside / polygon.length;
}
