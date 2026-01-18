// import 'package:flutter/material.dart';
//
// class DrawingAction {
//   final String id;
//   final String type; // 'draw', 'line', 'circle', 'rectangle'
//   final List<Offset> points;
//   final Color color;
//   final double strokeWidth;
//   final String userId;
//   final int? timestamp;
//   final String? text;
//
//
//   DrawingAction( {
//     required this.id,
//     required this.type,
//     required this.points,
//     required this.color,
//     required this.strokeWidth,
//     required this.userId,
//     required this.text,
//     this.timestamp,
//
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'type': type,
//     'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
//     'color': color.value,
//     'strokeWidth': strokeWidth,
//     'userId': userId,
//     if (timestamp != null) 'timestamp': timestamp,
//   };
//
//   factory DrawingAction.fromJson(Map<String, dynamic> json) {
//     try {
//       return DrawingAction(
//         id: json['id'] ?? '',
//         type: json['type'] ?? 'draw',
//         points: (json['points'] as List?)
//             ?.map((p) => Offset(
//           (p['x'] ?? 0.0).toDouble(),
//           (p['y'] ?? 0.0).toDouble(),
//         ))
//             .toList() ??
//             [],
//         color: Color(json['color'] ?? 0xFF000000),
//         strokeWidth: (json['strokeWidth'] ?? 3.0).toDouble(),
//         userId: json['userId'] ?? '',
//         timestamp: json['timestamp'], text: '',
//       );
//     } catch (e) {
//       print('Error parsing DrawAction: $e');
//       // Return a default action if parsing fails
//       return DrawingAction(
//         id: '',
//         type: 'draw',
//         points: [],
//         color: Colors.black,
//         strokeWidth: 3.0,
//         userId: '', text: '',
//       );
//     }
//   }
//
//   DrawingAction copyWith({
//     String? id,
//     String? type,
//     List<Offset>? points,
//     Color? color,
//     double? strokeWidth,
//     String? userId,
//     int? timestamp,
//   }) {
//     return DrawingAction(
//       id: id ?? this.id,
//       type: type ?? this.type,
//       points: points ?? this.points,
//       color: color ?? this.color,
//       strokeWidth: strokeWidth ?? this.strokeWidth,
//       userId: userId ?? this.userId,
//       timestamp: timestamp ?? this.timestamp, text: '',
//     );
//   }
// }


import 'package:flutter/material.dart';

class DrawingAction {
  final String id;
  final String type; // 'draw', 'text'
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String userId;
  final int? timestamp;

  // TEXT RELATED
  final String? text;
  final Offset? textPosition;

  DrawingAction({
    required this.id,
    required this.type,
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.userId,
    this.timestamp,
    this.text,
    this.textPosition,
  });

  /// TEXT CONSTRUCTOR
  DrawingAction.text({
    required this.id,
    required this.text,
    required this.textPosition,
    required this.color,
    required this.userId,
  })  : type = 'text',
        points = const [],
        strokeWidth = 0,
        timestamp = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'points':
    points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    'color': color.value,
    'strokeWidth': strokeWidth,
    'userId': userId,
    'timestamp': timestamp,
    'text': text,
    'textPosition': textPosition == null
        ? null
        : {
      'x': textPosition!.dx,
      'y': textPosition!.dy,
    },
  };

  factory DrawingAction.fromJson(Map<String, dynamic> json) {
    try {
      return DrawingAction(
        id: json['id'] ?? '',
        type: json['type'] ?? 'draw',
        points: (json['points'] as List?)
            ?.map((p) => Offset(
          (p['x'] ?? 0).toDouble(),
          (p['y'] ?? 0).toDouble(),
        ))
            .toList() ??
            [],
        color: Color(json['color'] ?? 0xFF000000),
        strokeWidth: (json['strokeWidth'] ?? 3.0).toDouble(),
        userId: json['userId'] ?? '',
        timestamp: json['timestamp'],
        text: json['text'],
        textPosition: json['textPosition'] == null
            ? null
            : Offset(
          (json['textPosition']['x']).toDouble(),
          (json['textPosition']['y']).toDouble(),
        ),
      );
    } catch (e) {
      debugPrint('Error parsing DrawingAction: $e');
      return DrawingAction(
        id: '',
        type: 'draw',
        points: [],
        color: Colors.black,
        strokeWidth: 3,
        userId: '',
      );
    }
  }
}
