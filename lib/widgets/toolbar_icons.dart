import 'package:draw_note/state/draw_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ToolIcon extends StatelessWidget {
  Function pushThisIcon;
  int seledtedIndex;
  bool selected;
  IconData iconsOfTool;

  ToolIcon(
      {Key? key,
      required this.pushThisIcon,
      required this.seledtedIndex,
      required this.selected,
      required this.iconsOfTool})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.white,
        // 선택된 경우 배경색을 파란색으로 설정
        shape: BoxShape.circle, // 동그란 모양으로 설정
      ),
      child: InkWell(
        onTap: (() {
          pushThisIcon(seledtedIndex);
        }),
        child: Icon(
          iconsOfTool,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class ToolBar extends StatefulWidget {
  ToolBar({Key? key})
      : super(
          key: key,
        );

  List<bool> selecteds = [
    true,
    false,
    false,
    false,
  ];

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawState>(builder: (context, drawState, _) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ToolIcon(
          pushThisIcon: drawState.setTool,
          seledtedIndex: 0,
          selected: drawState.selectedTools[0],
          iconsOfTool: drawState.toolIcons[0],
        ),
        ToolIcon(
          pushThisIcon: drawState.setTool,
          seledtedIndex: 1,
          selected: drawState.selectedTools[1],
          iconsOfTool: drawState.toolIcons[1],
        ),
        ToolIcon(
          pushThisIcon: drawState.setTool,
          seledtedIndex: 2,
          selected: drawState.selectedTools[2],
          iconsOfTool: drawState.toolIcons[2],
        ),
        ToolIcon(
          pushThisIcon: drawState.setTool,
          seledtedIndex: 3,
          selected: drawState.selectedTools[3],
          iconsOfTool: drawState.toolIcons[3],
        ),
        SizedBox(width: 15),
        IconButton(onPressed: (() {}), icon: Icon(FontAwesomeIcons.image)),
        IconButton(
            onPressed: (() {
              drawState.undo();
            }),
            icon: Icon(
              Icons.undo,
              color: (drawState.lines.length == 0) ? Colors.grey : Colors.black,
            )),
        IconButton(
            onPressed: (() {
              drawState.redo();
            }),
            icon: Icon(
              Icons.redo,
              color: (drawState.undoneLines.length == 0) ? Colors.grey : Colors.black,
            )),
        IconButton(onPressed: (() {}), icon: Icon(Icons.share)),
        SizedBox(width: 40),
        // IconButton(onPressed: (() {}), icon: Icon(Icons.highlight_alt)),
        // IconButton(onPressed: (() {}), icon: Icon(Icons.edit_square)),
        // IconButton(onPressed: (() {}), icon: Icon(Icons.draw)),
        // IconButton(onPressed: (() {}), icon: Icon(Icons.cleaning_services)),
        // IconButton(onPressed: (() {}), icon: Icon(Icons.delete)),
        // IconButton(onPressed: (() {}), icon: Icon(Icons.palette)),
        // IconButton(onPressed: (() {}), icon: Icon(CupertinoIcons.hand_draw)),
        // IconButton(onPressed: (() {}), icon: Icon(CupertinoIcons.fullscreen)),
      ]);
    });
  }
}
