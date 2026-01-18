import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_whiteboard/utils/constants.dart';
import '../models/User.dart';
import '../utils/prefs.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String baseUrl = AppConstants.baseUrl; 

  
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    try {
      print('Login attempt with: $emailOrUsername');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailOrUsername, 
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
    
        if (data['userId'] == null || data['username'] == null) {
          return {
            'success': false,
            'message': 'Invalid response from server',
          };
        }

       
        await Prefs.setUserId(data['userId']);
        await Prefs.setUsername(data['username']);
        if (data['token'] != null) {
          await Prefs.setAuthToken(data['token']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': AuthUser.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Connection error. Please check your internet and backend server.',
      };
    }
  }

 
  Future<Map<String, dynamic>> register(
      String username,
      String email,
      String password,
      ) async {
    try {
      print('Register attempt: username=$username, email=$email');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
      
        if (data['userId'] == null || data['username'] == null) {
          return {
            'success': false,
            'message': 'Invalid response from server',
          };
        }

 
        await Prefs.setUserId(data['userId']);
        await Prefs.setUsername(data['username']);
        if (data['token'] != null) {
          await Prefs.setAuthToken(data['token']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': AuthUser.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message': 'Connection error. Please check your internet and backend server.',
      };
    }
  }

  
  Future<void> logout() async {
    await Prefs.setUserId('');
    await Prefs.setUsername('');
    await Prefs.setAuthToken('');
  }


  bool isLoggedIn() {
    final userId = Prefs.getUserId();
    final username = Prefs.getUsername();
    return userId != null && userId.isNotEmpty &&
        username != null && username.isNotEmpty;
  }


  AuthUser? getCurrentUser() {
    final userId = Prefs.getUserId();
    final username = Prefs.getUsername();
    final token = Prefs.getAuthToken();

    if (userId != null && username != null) {
      return AuthUser(
        userId: userId,
        username: username,
        token: token,
      );
    }
    return null;
  }
}