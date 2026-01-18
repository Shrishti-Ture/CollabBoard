import 'package:flutter/material.dart';

// Authenticated User (from login/register)
class AuthUser {
  final String userId;
  final String username;
  final String? email;
  final String? token;

  AuthUser({
    required this.userId,
    required this.username,
    this.email,
    this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    if (email != null) 'email': email,
    if (token != null) 'token': token,
  };
}

// Whiteboard Participant (for real-time collaboration)
class WhiteboardUser {
  final String socketId;
  final String userId;
  final String username;
  final String role;
  final Color color;

  WhiteboardUser({
    required this.socketId,
    required this.userId,
    required this.username,
    required this.role,
    required this.color,
  });

  factory WhiteboardUser.fromJson(Map<String, dynamic> json) {
    return WhiteboardUser(
      socketId: json['socketId'],// ?? json['id'] ?? '',
      userId: json['userId'] ,//?? '',
      username: json['username'] ,
        role: json['role'], // host | participant//?? json['name'] ?? 'Anonymous',
      color: Color(json['color'] ,//?? 0xFF000000),
      )
    );
  }

  Map<String, dynamic> toJson() => {
    'socketId': socketId,
    'userId': userId,
    'username': username,
    'role':role,
    'color': color.value,
  };
}