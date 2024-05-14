import 'dart:ui';

import 'package:draw_note/load_string.dart';
import 'package:draw_note/widgets/toolbar_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'state/draw_state.dart';

class DrawEdit extends StatefulWidget {
  DrawEdit({Key? key}) : super(key: key);

  @override
  State<DrawEdit> createState() => DrawEditState();
}

class DrawEditState extends State<DrawEdit> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawState>(builder: (context, drawState, _) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
                color: Colors.white,
              ),
              child: GestureDetector(
                onPanDown: (DragDownDetails details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset point = box.globalToLocal(details.globalPosition);
                  drawState.onPanDown(point);
                },
                onPanUpdate: (DragUpdateDetails details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset point = box.globalToLocal(details.globalPosition);
                  drawState.onPanUpdate(point);
                },
                onPanEnd: (DragEndDetails details) {
                  drawState.onPanEnd(details);
                },
                child: CustomPaint(
                    painter: Signature(
                        lines: drawState.lines,
                        selectedResult: drawState.selectedPolygon),
                    size: Size.infinite),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.save)),
              IconButton(onPressed: () async{
                String? linesAsString = await loadString();
                if (linesAsString != null) {
                  drawState.loadLines(linesAsString);
                }
              }, icon: Icon(Icons.upload_file_rounded)),
              IconButton(onPressed: () {
                print(drawState.linesAsString);
              }, icon: Icon(Icons.print)),
            ],
          ),
          ToolBar(),
        ],
      );
    });
  }
}

class Signature extends CustomPainter {
  List<List<Offset>> lines;
  List<Offset> selectedResult;

  Signature({required this.lines, required this.selectedResult});

  void paint(Canvas canvas, Size size) {
    drawStrokes(canvas);
    drawSelectedArea(canvas);
  }

  void drawStrokes(Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;
    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        if (line[i] != null && line[i + 1] != null)
          canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  void drawSelectedArea(Canvas canvas) {
    if (selectedResult.length != 0) {
      // Define the points of your polygon
      List<Offset> points = selectedResult;
      // Create a new paint for filling the polygon
      final fillPaint = Paint()
        ..color = Colors.lightBlueAccent.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      // Draw the filled polygon
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, fillPaint);
      // Create a new paint for drawing the dashed lines
      final dashedPaint = Paint()
        ..color = Colors.lightBlue
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = 1.0;
      // Draw the dashed lines
      for (int i = 0; i < points.length - 1; i++) {
        drawDashedLine(canvas, points[i], points[i + 1], dashedPaint);
      }
      drawDashedLine(canvas, points[points.length - 1], points[0], dashedPaint);
    }
  }

  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 5;
    const double gapLength = 5;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    for (PathMetric metric in path.computeMetrics()) {
      double distance = dashLength;
      while (distance < metric.length) {
        double remainingDistance = metric.length - distance;
        double currentDashLength = dashLength;
        if (remainingDistance < dashLength + gapLength) {
          currentDashLength = remainingDistance;
        }
        final Path extractedPath =
            metric.extractPath(distance - dashLength, distance);
        canvas.drawPath(extractedPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  bool shouldRepaint(Signature oldDelegate) => true;
}