import 'package:flutter/material.dart';
import '../models/DrawingAction.dart';
import '../models/User.dart';
import '../utils/constants.dart';

class WhiteboardPainter extends CustomPainter {
  final List<DrawingAction> actions;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentStrokeWidth;
  final String drawMode;
  final Map<String, Offset> userCursors;
  final Map<String, WhiteboardUser> users;

  WhiteboardPainter({
    required this.actions,
    required this.currentPoints,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.drawMode,
    required this.userCursors,
    required this.users,
  });

  @override
  void paint(Canvas canvas, Size size) {
  
    for (final action in actions) {
      _drawAction(canvas, action);
      if (action.type == 'text') {
        final textPainter = TextPainter(
          text: TextSpan(
            text: action.text ?? '',
            style: TextStyle(
              color: action.color,
              fontSize: action.strokeWidth * 4,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        final position = action.points.first;
        textPainter.paint(canvas, position);
        continue;
      }
    }

    if (currentPoints.isNotEmpty) {
      _drawAction(
        canvas,
        DrawingAction(
          id: 'temp',
          type: drawMode,
          points: currentPoints,
          color: currentColor,
          strokeWidth: currentStrokeWidth,
          userId: '', text: '',
        ),
      );
    }

  
    _drawUserCursors(canvas);
  }

  void _drawAction(Canvas canvas, DrawingAction action) {
    if (action.points.isEmpty) return;

    final paint = Paint()
      ..color = action.color
      ..strokeWidth = action.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (action.type) {
      case AppConstants.drawModeDraw:
        _drawFreehand(canvas, action, paint);
        break;
      case AppConstants.drawModeLine:
        _drawLine(canvas, action, paint);
        break;
      case AppConstants.drawModeCircle:
        _drawCircle(canvas, action, paint);
        break;
      case AppConstants.drawModeRectangle:
        _drawRectangle(canvas, action, paint);
        break;
    }
  }

  void _drawFreehand(Canvas canvas, DrawingAction action, Paint paint) {
    if (action.points.length < 2) {
  
      final dotPaint = Paint()
        ..color = action.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(action.points.first, action.strokeWidth / 2, dotPaint);
    } else {
      final path = Path();
      path.moveTo(action.points.first.dx, action.points.first.dy);
      for (int i = 1; i < action.points.length; i++) {
        path.lineTo(action.points[i].dx, action.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawLine(Canvas canvas, DrawingAction action, Paint paint) {
    if (action.points.length >= 2) {
      canvas.drawLine(action.points.first, action.points.last, paint);
    }
  }

  void _drawCircle(Canvas canvas, DrawingAction action, Paint paint) {
    if (action.points.length >= 2) {
      final center = action.points.first;
      final radius = (action.points.last - center).distance;
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawRectangle(Canvas canvas, DrawingAction action, Paint paint) {
    if (action.points.length >= 2) {
      final rect = Rect.fromPoints(action.points.first, action.points.last);
      canvas.drawRect(rect, paint);
    }
  }

  void _drawUserCursors(Canvas canvas) {
    for (var entry in userCursors.entries) {
      final user = users[entry.key];
      if (user != null) {
      
        final paint = Paint()
          ..color = user.color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(entry.value, AppConstants.cursorSize, paint);

     
        final textSpan = TextSpan(
          text: user.username,
          style: TextStyle(
            color: user.color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white.withOpacity(0.9),
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

      
        final bgRect = Rect.fromLTWH(
          entry.value.dx + 10,
          entry.value.dy - 8,
          textPainter.width + 4,
          textPainter.height + 2,
        );

        canvas.drawRect(
          bgRect,
          Paint()..color = Colors.white.withOpacity(0.9),
        );

        textPainter.paint(canvas, entry.value + const Offset(12, -7));
      }
    }
  }

  @override
  bool shouldRepaint(WhiteboardPainter oldDelegate) => true;
}