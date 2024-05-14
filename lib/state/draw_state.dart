import 'dart:async';
import 'package:draw_note/functions/eraser.dart';
import 'package:draw_note/functions/select.dart';
import 'package:draw_note/save_load_lines.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../functions/tools.dart';

class DrawState extends ChangeNotifier {
  static double minPercentInside = 0.8;

  List<bool> selectedTools = [
    true,
    false,
    false,
    false,
  ];
  var tools = [
    ToolType.pen,
    ToolType.eraser,
    ToolType.select,
    ToolType.textEdit
  ];
  var toolIcons = [
    FontAwesomeIcons.pen,
    FontAwesomeIcons.eraser,
    CupertinoIcons.lasso,
    Icons.text_fields
  ];

  ToolType currentTool = ToolType.pen;

  List<List<Offset>> _lines = <List<Offset>>[];
  List<List<Offset>> _undoneLines = <List<Offset>>[];

  List<Offset> selectedPolygon = <Offset>[];
  Path selectedPolygonPath = Path();
  Set<int> selectedLines = <int>{};
  Offset currentPosition = Offset(0, 0);

  bool doneSelecting = false;

  Timer? _timer;

  List<List<Offset>> get lines => _lines;

  List<List<Offset>> get undoneLines => _undoneLines;

  String get linesAsString => getEncodedLines(_lines);

  void loadLines(String linesAsString) {
    _lines = getDecodedLines(linesAsString);
    notifyListeners();
  }

  void setTool(int index) {
    if (index < selectedTools.length) {
      selectedTools = [
        false,
        false,
        false,
        false,
      ];
      selectedTools[index] = true;
      currentTool = tools[index];
      notifyListeners();
    }
  }

  void undo() {
    if (_lines.isNotEmpty) {
      _undoneLines.add(_lines.removeLast());
    }
    notifyListeners();
  }

  void redo() {
    if (_undoneLines.isNotEmpty) {
      _lines.add(_undoneLines.removeLast());
    }
    notifyListeners();
  }

  void clearAll() {
    _lines = <List<Offset>>[];
    notifyListeners();
  }

  void onPanDown(Offset point) {
    if (currentTool == ToolType.pen) {
      _lines.add(<Offset>[]);
      _timer?.cancel();
    } else if (currentTool == ToolType.eraser) {
    } else if (currentTool == ToolType.select) {
      if (doneSelecting & selectedPolygonPath.contains(point)) {
        // Do Nothing
      } else {
        doneSelecting = false;
        selectedPolygon = [];
        selectedPolygonPath = Path();
        selectedLines = <int>{};
      }
    }
    currentPosition = point;
    notifyListeners();
  }

  void onPanUpdate(Offset point) {
    if (currentTool == ToolType.pen) {
      _lines.last.add(point);
      _timer?.cancel();
    }
    else if (currentTool == ToolType.eraser) {
      for (List<Offset> stroke in checkForOverlappingStrokes(point, _lines)) {
        _lines.remove(stroke);
      }
    }
    else if (currentTool == ToolType.select) {
      final deltaToMove = point - currentPosition;
      if (doneSelecting) {
        for (int lineIndex in selectedLines) {
          List<Offset> newLine = [];
          _lines[lineIndex].forEach((pt) {
            newLine.add(pt + deltaToMove);
          });
          _lines[lineIndex] = newLine;
        }
        List<Offset> newSelectedPolygon = [];
        selectedPolygon.forEach((pt) {
          newSelectedPolygon.add(pt + deltaToMove);
        });
        selectedPolygon = newSelectedPolygon;
      } else {
        selectedPolygon.add(point);
      }
    }
    currentPosition = point;
    notifyListeners();
  }

  void onPanEnd(DragEndDetails details) {
    if (currentTool == ToolType.pen) {
      _timer = Timer(Duration(seconds: 2), () {
        _lines.add(<Offset>[]);
      });
    } else if (currentTool == ToolType.eraser) {
    } else if (currentTool == ToolType.select) {
      if (doneSelecting) {
      } else {
        doneSelecting = true;
        selectedPolygonPath = getPath(selectedPolygon);
        for (int i = 0; i < _lines.length; i++) {
          final line = _lines[i];
          final percentInside = polygonPercentInside(selectedPolygonPath, line);
          if (percentInside > minPercentInside) {
            selectedLines.add(i);
          }
        }
        if (selectedLines.length == 0) {
          doneSelecting = false;
          selectedPolygon = [];
          selectedPolygonPath = Path();
          selectedLines = <int>{};
        }
      }
    }
    notifyListeners();
  }
//
// void onDrawStart(ScaleStartDetails details) {
//   final page = coreInfo.pages[dragPageIndex!];
//   final position = page.renderBox!.globalToLocal(details.focalPoint);
//   history.canRedo = false;
//
//   if (currentTool is Pen) {
//     (currentTool as Pen)
//         .onDragStart(position, dragPageIndex!, currentPressure);
//   } else if (currentTool is Eraser) {
//     for (Stroke stroke in (currentTool as Eraser)
//         .checkForOverlappingStrokes(position, page.strokes)) {
//       page.strokes.remove(stroke);
//     }
//     removeExcessPages();
//   } else if (currentTool is Select) {
//     Select select = currentTool as Select;
//     if (select.doneSelecting &&
//         select.selectResult.pageIndex == dragPageIndex! &&
//         select.selectResult.path.contains(position)) {
//       // drag selection in onDrawUpdate
//     } else {
//       select.onDragStart(position, dragPageIndex!);
//       history.canRedo = true; // selection doesn't affect history
//     }
//   } else if (currentTool is LaserPointer) {
//     (currentTool as LaserPointer).onDragStart(position, dragPageIndex!);
//   }
//
//   previousPosition = position;
//   moveOffset = Offset.zero;
//
//   if (currentTool is! Select) {
//     Select.currentSelect.unselect();
//   }
//
//   // setState to let canvas know about currentStroke
//   setState(() {});
// }
//
// void onDrawUpdate(ScaleUpdateDetails details) {
//   if (currentTool == ToolType.pen) {
//     _lines.add(<Offset>[]);
//     _timer?.cancel();
//     notifyListeners();
//   } else if (currentTool == ToolType.eraser) {
//     for (Stroke stroke in (currentTool as Eraser)
//         .checkForOverlappingStrokes(position, page.strokes)) {
//       page.strokes.remove(stroke);
//     }
//     page.redrawStrokes();
//     removeExcessPages();
//   } else if (currentTool == ToolType.select) {
//     Select select = currentTool as Select;
//     if (select.doneSelecting) {
//       for (Stroke stroke in select.selectResult.strokes) {
//         stroke.shift(offset);
//       }
//       for (EditorImage image in select.selectResult.images) {
//         image.dstRect = image.dstRect.shift(offset);
//       }
//       select.selectResult.path = select.selectResult.path.shift(offset);
//     } else {
//       select.onDragUpdate(position);
//     }
//     page.redrawStrokes();
//   } else {}
// }
//
// void onDrawEnd(ScaleEndDetails details) {
//   final page = coreInfo.pages[dragPageIndex!];
//   setState(() {
//     if (currentTool is Pen) {
//       Stroke newStroke = (currentTool as Pen).onDragEnd();
//       if (newStroke.isEmpty) return;
//       createPage(newStroke.pageIndex);
//       page.insertStroke(newStroke);
//       history.recordChange(EditorHistoryItem(
//         type: EditorHistoryItemType.draw,
//         pageIndex: dragPageIndex!,
//         strokes: [newStroke],
//         images: [],
//       ));
//     } else if (currentTool is Eraser) {
//       final erased = (currentTool as Eraser).onDragEnd();
//       if (stylusButtonPressed || Prefs.disableEraserAfterUse.value) {
//         // restore previous tool
//         stylusButtonPressed = false;
//         currentTool = tmpTool!;
//         tmpTool = null;
//       }
//       if (erased.isEmpty) return;
//       history.recordChange(EditorHistoryItem(
//         type: EditorHistoryItemType.erase,
//         pageIndex: dragPageIndex!,
//         strokes: erased,
//         images: [],
//       ));
//     } else if (currentTool is Select) {
//       if (moveOffset == Offset.zero) return;
//       Select select = currentTool as Select;
//       if (select.doneSelecting) {
//         history.recordChange(EditorHistoryItem(
//           type: EditorHistoryItemType.move,
//           pageIndex: dragPageIndex!,
//           strokes: select.selectResult.strokes,
//           images: select.selectResult.images,
//           offset: Rect.fromLTRB(
//             moveOffset.dx,
//             moveOffset.dy,
//             moveOffset.dx,
//             moveOffset.dy,
//           ),
//         ));
//       } else {
//         select.onDragEnd(page.strokes, page.images);
//
//         if (select.selectResult.isEmpty) {
//           Select.currentSelect.unselect();
//         }
//       }
//     } else if (currentTool is LaserPointer) {
//       Stroke newStroke = (currentTool as LaserPointer).onDragEnd(
//         page.redrawStrokes,
//         (Stroke stroke) {
//           page.laserStrokes.remove(stroke);
//         },
//       );
//       page.laserStrokes.add(newStroke);
//     }
//   });
//   autosaveAfterDelay();
// }
}
