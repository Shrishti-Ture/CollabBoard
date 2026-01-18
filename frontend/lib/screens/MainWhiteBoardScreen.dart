import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_whiteboard/utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/DrawingAction.dart';
import '../models/User.dart';
import '../services/socketService.dart';
import '../widgets/whiteboard_canvas.dart';
import '../widgets/participantsDrawer.dart';

class MainWhiteBoardScreen extends StatefulWidget {
  final String roomId;
  final String userId;
  final String username;
final bool isHost;
  const MainWhiteBoardScreen({
    Key? key,
    required this.roomId,
    required this.userId,
    required this.username,
    required this.isHost,
  }) : super(key: key);

  @override
  State<MainWhiteBoardScreen> createState() => _MainWhiteBoardScreenState();
}

class _MainWhiteBoardScreenState extends State<MainWhiteBoardScreen> {
  final SocketService _socketService = SocketService();
  final List<DrawingAction> _drawingActions = [];
  final Map<String, WhiteboardUser> _users = {};
  final Map<String, Offset> _userCursors = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<bool>? _connectionSub;

  String? currentSocketId;
  bool socketReady = false;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  double _eraserRadius = 20.0;

  String _drawMode = 'draw'; 

  List<Offset> _currentPoints = [];
  bool _isDrawing = false;
  bool _isConnected = false;

  bool _hasJoinedRoom = false;

  final String _serverUrl = AppConstants.baseUrl;
  bool _socketStarted = false;
  @override
  void initState() {
    super.initState();
    if (!_socketStarted) {
      _socketStarted = true;
      _connectToServer();
      _setupSocketListeners(); 
    }
  }



  Future<void> _connectToServer() async {
    try {
      await _socketService.connect(_serverUrl);

      _connectionSub ??= _socketService.connectionStream.listen((connected) {
        if (!mounted) return;

      setState(() => _isConnected = connected);

        if (connected && !_hasJoinedRoom) {
          print("SOCKET CONNECTED → joining room");
          _hasJoinedRoom=true;
          _joinRoom();
        }
      });
    } catch (e) {
      _showSnackBar('Connection failed: $e');
    }
  }

  void _setupSocketListeners() {
    _socketService.on('room-update', (data) {
      if (!mounted) return;

      final users = data['users'];
      if (users == null) return;

      setState(() {
        _users.clear();

        for (final u in users) {
          final user = WhiteboardUser(
            socketId: u['socketId'],
            userId: u['userId'],
            username: u['username'],
            role: u['role'],
            color: Color(
              int.parse(u['color'].replaceFirst('#', '0xff')),
            ),
          );

          _users[user.socketId] = user;
        }
      });
    });



  
    _socketService.on('user-left', (data) {
      setState(() {
        _users.remove(data['socketId']);
        _userCursors.remove(data['userId']);
      });
      _showSnackBar('${data['userName']} left');
    });

  
    _socketService.on('draw-action', (data) {
      setState(() => _drawingActions.add(DrawingAction.fromJson(data)));
    });

    
    _socketService.on('cursor-move', (data) {
      setState(() {
        _userCursors[data['userId']] = Offset(
          data['x'].toDouble(),
          data['y'].toDouble(),
        );
      });
    });
    _socketService.on('room-closed', (_) {
      Navigator.pop(context);
    });



    _socketService.on('board-cleared', (_) {
      setState(() => _drawingActions.clear());
    });

  
    _socketService.on('action-undone', (data) {
      setState(() => _drawingActions.removeWhere((a) => a.id == data['id']));
    });

    _socketService.on('kicked', (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You were removed by host')),
      );
      _socketService.disconnect();
      Navigator.pop(context);
    });
  }



  void _joinRoom() {
    _users[_socketService.socketId ?? 'local'] = WhiteboardUser(
      socketId: _socketService.socketId ?? 'local',
      userId: widget.userId,
      username: widget.username,
      role: widget.isHost ? 'host' : 'participant',
      color: Colors.blue,
    );

    if (widget.isHost) {
      _socketService.emit('create-room', {
        'roomId': widget.roomId,
        'userId': widget.userId,
        'userName': widget.username,
      });
    } else {
      _socketService.emit('join-room', {
        'roomId': widget.roomId,
        'userId': widget.userId,
        'userName': widget.username,
      });
    }
  }



  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentPoints = [details.localPosition];
    });
  }

 
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    final position = details.localPosition;

    if (_drawMode == 'eraser') {
      setState(() {
        _drawingActions.removeWhere((action) {
          if (action.type == 'text') {
          
            final textPos = action.points.first;
            return (textPos - position).distance < _eraserRadius;
          } else {
          
            return action.points.any((p) => (p - position).distance < _eraserRadius);
          }
        });
      });
      return;
    }

    setState(() => _currentPoints.add(position));
  }




  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing || _currentPoints.isEmpty) return;

    final action = DrawingAction(
      id: const Uuid().v4(),
      type: _drawMode,
      points: List.from(_currentPoints),
      color: _selectedColor,
      strokeWidth: _strokeWidth,
      userId: _socketService.socketId ?? '', text: '',
    );

    setState(() {
      _drawingActions.add(action);
      _isDrawing = false;
      _currentPoints = [];
    });

    if (_isConnected) {
      _socketService.emit('draw-action', {
        ...action.toJson(),
        'roomId': widget.roomId,
      });
    }
  }

  void _clearBoard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Board'),
        content: const Text('Clear the entire whiteboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _drawingActions.clear());

              _socketService.emit('clear-board', {
                'roomId': widget.roomId,
              });

              Navigator.pop(context);
            },

            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _onCanvasTap(Offset position) async {
    if (_drawMode != 'text') return;

    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter text'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (text == null || text.trim().isEmpty) return;

    final action = DrawingAction(
      id: const Uuid().v4(),
      type: 'text',
      points: [position],
      color: _selectedColor,
      strokeWidth: _strokeWidth,
      userId: _socketService.socketId ?? '',
      text: text,
    );

    setState(() => _drawingActions.add(action));
    _socketService.emit('draw-action', action.toJson());
  }

  void _handleTextTap(Offset position) async {
    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (text == null || text.trim().isEmpty) return;

    final action = DrawingAction.text(
      id: UniqueKey().toString(),
      text: text,
      textPosition: position,
      color: _selectedColor,
      userId: widget.userId,
    );

    setState(() => _drawingActions.add(action));

    _socketService.emit('draw-action', action.toJson());
  }


  void _undo() {
    if (_drawingActions.isEmpty) return;

    final lastAction = _drawingActions.last;

    setState(() => _drawingActions.removeLast());

    _socketService.emit('undo-action', {
      'roomId': widget.roomId,
      'actionId': lastAction.id,
    });
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }


  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.roomId));
    _showSnackBar('Room ID copied to clipboard');
  }

  void _leaveRoom() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Leave Room"),
        content: const Text("Are you sure you want to leave this room?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
             
              _socketService.emit('leave-room', {
                'roomId': widget.roomId,
              });

              
              _socketService.disconnect();

              
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text("Leave"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('Room: ${widget.roomId}'),
            const SizedBox(width: 8),
            Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              size: 20,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyRoomId,
            tooltip: 'Copy Room ID',
          ),
          IconButton(
            icon: Badge(
              label: Text('${_users.length}'),
              child: const Icon(Icons.people),
            ),
            onPressed: () => {
              _scaffoldKey.currentState?.openEndDrawer()
              },
            tooltip: 'Participants',
          ),
          IconButton(onPressed: _leaveRoom,
              tooltip:'Leave Room',
              icon: const Icon(Icons.exit_to_app,)),
          if (widget.isHost)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close Room',
              onPressed: () {
                _socketService.emit('close-room', {
                  'roomId': widget.roomId,
                });
              },
            ),


        ],

      ),
            endDrawer: Drawer(
              child: _socketService.socketId == null
                  ? const Center(child: CircularProgressIndicator())
                  : ParticipantsDrawer(
                users: _users,
                roomId: widget.roomId,
                currentUsername: widget.username,
                currentSocketId: _socketService.socketId!,
                socketService: _socketService,
              ),
            ),


            body: Row(
        children: [
          _buildVerticalToolbar(),
          Expanded(
            child: WhiteboardCanvas(
              drawingActions: _drawingActions,
              currentPoints: _currentPoints,
              currentColor: _selectedColor,
              currentStrokeWidth: _strokeWidth,
              drawMode: _drawMode,
              userCursors: _userCursors,
              users: _users,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTextTap: _handleTextTap,
              onTap: _onCanvasTap, 
            ),

          ),
        ],
      ),
    ));
  }


  Widget _buildVerticalToolbar() {
    return Container(
      width: 56,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildToolButton(Icons.edit, 'draw', 'Draw'),
          _buildToolButton(Icons.remove, 'eraser', 'Eraser'),
          _buildToolButton(Icons.text_fields, 'text', 'Text'),
          const Divider(),

          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),

          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearBoard,
          ),

          const Spacer(),

          GestureDetector(
            onTap: _pickColor,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _selectedColor,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }


  Widget _buildToolButton(IconData icon, String mode, String tooltip) {
    return IconButton(
      icon: Icon(icon, color: _drawMode == mode ? Colors.blue : Colors.black),
      onPressed: () {
        setState(() {
          _drawMode = mode;
          if (mode == 'eraser') {
            _eraserRadius = _strokeWidth * 2;
          }
        });
      },

      tooltip: tooltip,
    );
  }


  // @override
  // void dispose() {
  //   _socketService.clearListeners();
  //   _socketService.disconnect();
  //   super.dispose();
  // }
  @override
  void dispose() {
    _connectionSub?.cancel();
    _connectionSub = null;

    _socketService.clearListeners();
    _socketService.disconnect();

    super.dispose();
  }


}


