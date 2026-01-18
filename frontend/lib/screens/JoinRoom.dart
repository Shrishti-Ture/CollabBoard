import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../utils/prefs.dart';
import 'MainWhiteBoardScreen.dart';
import 'LoginScreen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  final _authService = AuthService();
  bool _isHost = false;

  String? _userId;
  String? _username;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    if (!_authService.isLoggedIn()) {
  
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return;
    }

    _userId = Prefs.getUserId();
    _username = Prefs.getUsername();
    setState(() {});
  }

  void _createRoom() {
    final roomId = const Uuid().v4().substring(0, 8).toUpperCase();

    setState(() {
      _roomIdController.text = roomId;
      _isHost = true; 
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainWhiteBoardScreen(
          roomId: roomId,
          userId: _userId!,
          username: _username!,
          isHost: _isHost, 
        ),
      ),
    );

    _roomIdController.clear();
  }


  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainWhiteBoardScreen(
          roomId: _roomIdController.text.trim(),
          userId: _userId!,
          username: _username!,
          isHost: _isHost,
        ),
      ),
    );

    setState(() {
      _isLoading = false;
      _isHost = false; 
    });

    _roomIdController.clear();
  }


  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null || _username == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  _username![0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _username!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout),
                                onPressed: _logout,
                                tooltip: 'Logout',
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Icon(
                          Icons.draw,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Collaborative Whiteboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create or join a room to start collaborating',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _roomIdController,
                          decoration: InputDecoration(
                            labelText: 'Room ID',
                            hintText: 'Enter or create room ID',
                            prefixIcon: const Icon(Icons.meeting_room),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.content_copy),
                              onPressed: () {
                                if (_roomIdController.text.isNotEmpty) {
                                  Clipboard.setData(
                                    ClipboardData(text: _roomIdController.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Room ID copied!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Copy Room ID',
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a room ID';
                            }
                            if (value.length < 4) {
                              return 'Room ID must be at least 4 characters';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _createRoom,
                                icon: const Icon(Icons.add),
                                label: const Text('Create Room'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _joinRoom,
                                icon: _isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(Icons.arrow_forward),
                                label: const Text('Join Room'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }
}