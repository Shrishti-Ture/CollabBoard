require("dotenv").config();
const express = require("express");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");

const connectDB = require("./mongoDb");

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" ,
    methods:["GET","POST"],
  },
});

require("./socket/socketController")(io);


app.use(cors());
app.use(express.json());

connectDB();


app.use("/api/auth", require("./routes/authRoutes"));


io.on("connection", (socket) => {
  console.log("User connected:", socket.id);
});


const PORT = process.env.PORT;
server.listen(PORT, () =>
  console.log(`Server running on port ${PORT}`)
);
