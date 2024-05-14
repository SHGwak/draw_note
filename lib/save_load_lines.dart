import 'dart:ui';

// Offset 객체를 문자열로 변환하는 함수
String offsetToString(Offset offset) {
  return '${offset.dx},${offset.dy}';
}

// 문자열을 Offset 객체로 변환하는 함수
Offset stringToOffset(String str) {
  final coords = str.split(',');
  return Offset(double.parse(coords[0]), double.parse(coords[1]));
}

String getEncodedLines(List<List<Offset>> lines) {
  return lines.map((line) => line.map(offsetToString).join(';')).join('|');
}

List<List<Offset>> getDecodedLines(String linesAsString) {
  return linesAsString.split('|').map((lineAsString) {
    return lineAsString.split(';').map(stringToOffset).toList();
  }).toList();
}