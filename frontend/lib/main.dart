import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_whiteboard/services/auth_service.dart';
import 'package:online_whiteboard/utils/prefs.dart';
import 'package:online_whiteboard/screens/JoinRoom.dart';
import 'package:online_whiteboard/screens/LoginScreen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  await Prefs.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const WhiteboardApp());
}

class WhiteboardApp extends StatelessWidget {
  const WhiteboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'Collaborative Whiteboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    
      home: authService.isLoggedIn()
          ? const JoinRoomScreen()
          : const LoginScreen(),
    );
  }
}