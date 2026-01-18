const getRandomColor = require("../utils/getRandomColor");

const rooms = {};

module.exports = (io) => {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

  
    socket.on("create-room", ({ roomId, userId, userName }) => {
      socket.join(roomId);

      rooms[roomId] = {
        hostSocketId: socket.id,
        members: {
          [socket.id]: {
            socketId: socket.id,
            userId,
            username: userName,
            role: "host",
            color: getRandomColor(),
          },
        },
        kickedUsers :new Set(),
        drawingData: [],
      };

      socket.emit("room-update", {
        users: Object.values(rooms[roomId].members),
      });

      console.log(`HOST ${userName} created room ${roomId}`);
    });

  


    socket.on("join-room", ({ roomId, userId, userName }) => {
      const room = rooms[roomId];
      if (!room) return;
      if (room.kickedUsers?.has(userId)) {
    socket.emit("kicked");
    return;
  }

      socket.join(roomId);

      room.members[socket.id] = {
        socketId: socket.id,
        userId,
        username: userName,
        role: "participant",
        color: getRandomColor(),
      };

      io.to(roomId).emit("room-update", {
        drawingData: room.drawingData,
        users: Object.values(room.members),
      });

      console.log(`${userName} joined room ${roomId}`);
    });

  


    socket.on("kick-user", ({ roomId, targetSocketId }) => {
      const room = rooms[roomId];
      if (!room) return;

      if (room.hostSocketId !== socket.id) return;
      const kickedUser = room.members[targetSocketId];
  if (!kickedUser) return;
  room.kickedUsers.add(kickedUser.userId);
     
  delete room.members[targetSocketId];
      io.sockets.sockets.get(targetSocketId)?.leave(roomId);
      io.to(targetSocketId).emit("kicked");

      io.to(roomId).emit("room-update", {
        users: Object.values(room.members),
      });

      console.log(`User kicked from ${roomId}`);
    });


    socket.on("undo-action", ({ roomId, actionId }) => {
  socket.to(roomId).emit("action-undone", {
    id: actionId,
  });
});

socket.on("clear-board", ({ roomId }) => {
  io.to(roomId).emit('clear-board');
});




    socket.on('draw-action', (data) => {
  const roomId = data.roomId;
const room = rooms[roomId];
      if (!room) return;

  room.drawingData.push(data);
  socket.to(roomId).emit('draw-action', data);
});


  


    socket.on("close-room", ({ roomId }) => {
      const room = rooms[roomId];
      if (!room) return;

      if (room.hostSocketId !== socket.id) return;

      io.to(roomId).emit("room-closed");
      delete rooms[roomId];

      console.log(`Room ${roomId} closed by host`);
    });




    socket.on("leave-room", ({ roomId }) => {
      handleLeaveRoom(socket, roomId, io);
    });

   


    socket.on("disconnect", () => {
      for (const roomId in rooms) {
        handleLeaveRoom(socket, roomId, io);
      }
    });
  });
};




function handleLeaveRoom(socket, roomId, io) {
  const room = rooms[roomId];
  if (!room) return;
  if (!room.members[socket.id]) return;

  const wasHost = room.hostSocketId === socket.id;

  delete room.members[socket.id];
  socket.leave(roomId);

  const members = Object.values(room.members);


  if (wasHost && members.length > 0) {
    room.hostSocketId = members[0].socketId;
    room.members[members[0].socketId].role = "host";
  }


  if (members.length === 0) {
    delete rooms[roomId];
    return;
  }

  io.to(roomId).emit("room-update", {
    users: Object.values(room.members),
  });
}
