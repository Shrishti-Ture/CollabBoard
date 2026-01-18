
import 'package:flutter/material.dart';
import '../models/DrawingAction.dart';
import '../models/User.dart';
import 'whiteboardpainter.dart';

class WhiteboardCanvas extends StatelessWidget {
  final List<DrawingAction> drawingActions;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentStrokeWidth;
  final String drawMode;
  final Map<String, Offset> userCursors;
  final Map<String, WhiteboardUser> users;

  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;


  final Function(Offset position)? onTextTap;
  final Function(Offset) onTap;

  const WhiteboardCanvas({
    Key? key,
    required this.drawingActions,
    required this.currentPoints,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.drawMode,
    required this.userCursors,
    required this.users,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onTap,

    this.onTextTap,
  }) : super(key: key);




  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTapDown: (details) {
            onTap(details.localPosition);
          },
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: CustomPaint(
            size: Size.infinite,
            painter: WhiteboardPainter(
              actions: drawingActions,
              currentPoints: currentPoints,
              currentColor: currentColor,
              currentStrokeWidth: currentStrokeWidth,
              drawMode: drawMode,
              userCursors: userCursors,
              users: users,
            ),
          ),
        ),
      ),
    );
  }
}
