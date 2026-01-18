import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _initialized = false;

  final _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;
  String? get socketId => _socket?.id;

  Future<void> connect(String serverUrl) async {
    if (_initialized) return;
    _initialized = true;

    print('Connecting to server: $serverUrl');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _setupCoreListeners();
    _socket!.connect();
  }

  void _setupCoreListeners() {
    _socket!.onConnect((_) {
      print('✅ Connected to server! Socket ID: ${_socket?.id}');
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('⚠️ Disconnected from server');
      _connectionController.add(false);
    });

    _socket!.onConnectError((data) {
      print('❌ Connection Error: $data');
      _connectionController.add(false);
    });

    _socket!.onError((data) {
      print('❌ Socket Error: $data');
    });
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket!.emit(event, data);
      print('📤 Emitted event: $event');
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void clearListeners() {
    _socket?.off('room-joined');
    _socket?.off('room-update');
    _socket?.off('user-joined');
    _socket?.off('user-left');
    _socket?.off('draw-action');
    _socket?.off('cursor-move');
    _socket?.off('board-cleared');
    _socket?.off('action-undone');
  }

  void disconnect() {
    if (_socket != null) {
      print('🔴 Destroying socket');
      _socket!.dispose(); 
      _socket = null;
    }
    _initialized = false;
  }
}

