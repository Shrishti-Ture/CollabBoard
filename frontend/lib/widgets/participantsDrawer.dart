

import 'package:flutter/material.dart';
import '../models/User.dart';
import '../services/socketService.dart';

class ParticipantsDrawer extends StatelessWidget {
  final Map<String, WhiteboardUser> users;
  final String roomId;
  final String currentUsername;
  final String currentSocketId;
  final SocketService socketService;

  const ParticipantsDrawer({
    Key? key,
    required this.users,
    required this.roomId,
    required this.currentUsername,
    required this.currentSocketId,
    required this.socketService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHost = users.values.any(
          (u) => u.socketId == currentSocketId && u.role == 'host',
    );

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Participants',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Room: $roomId',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${users.length} online',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? const Center(child: Text('No participants'))
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users.values.elementAt(index);
                final isCurrentUser =
                    user.username == currentUsername;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.color,
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(user.username),

                      if (user.role == 'host')
                        Container(
                          margin:
                          const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white),
                          ),
                        ),

                      if (isCurrentUser)
                        Container(
                          margin:
                          const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white),
                          ),
                        ),

                      if (isHost && user.role != 'host')
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            socketService.emit(
                              'kick-user',
                              {
                                'roomId': roomId,
                                'targetSocketId':
                                user.socketId,
                              },
                            );
                          },
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'ID: ${user.userId.substring(0, 8)}...',
                    style:
                    const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
