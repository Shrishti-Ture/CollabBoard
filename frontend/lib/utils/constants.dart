import 'package:flutter/material.dart';

class AppConstants {
  
  static const String eventJoinRoom = 'join-room';
  static const String eventLeaveRoom = 'leave-room';
  static const String eventRoomJoined = 'room-joined';
  static const String eventUserJoined = 'user-joined';
  static const String eventUserLeft = 'user-left';
  static const String eventDrawAction = 'draw-action';
  static const String eventCursorMove = 'cursor-move';
  static const String eventClearBoard = 'clear-board';
  static const String eventBoardCleared = 'board-cleared';
  static const String eventUndoAction = 'undo-action';
  static const String eventActionUndone = 'action-undone';

  
  static const String drawModeDraw = 'draw';
  static const String drawModeLine = 'line';
  static const String drawModeCircle = 'circle';
  static const String drawModeRectangle = 'rectangle';

  static const double defaultStrokeWidth = 3.0;
  static const double minStrokeWidth = 1.0;
  static const double maxStrokeWidth = 20.0;


  static const Color primaryColor = Colors.blue;
  static const Color backgroundColor = Colors.white;
  static const Color toolbarColor = Color(0xFFEEEEEE);


  static const List<Color> predefinedColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  static const double toolbarHeight = 60.0;
  static const double iconButtonSize = 48.0;
  static const double colorPickerSize = 36.0;
  static const double cursorSize = 6.0;


  static const String baseUrl = 'http://IPv4address:PORT';


  static const String keyUserId = 'userId';
  static const String keyUsername = 'username';
  static const String keyAuthToken = 'authToken';
  static const String keyServerUrl = 'serverUrl';
  static const String keyLastRoomId = 'lastRoomId';
}