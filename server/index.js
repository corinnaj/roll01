const app = require("express")();
const http = require("http").createServer(app);
const io = require("socket.io")(http);

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

io.on("connection", (socket) => {
  console.log('connection')

  socket.emit('hi', 'hello');
  socket.broadcast.emit("request_join", { requesterSocketId: socket.id });

  socket.on("answer_join", (data) => {
    console.log('answering join')
    io.to(data.requesterSocketId).emit("init_commands", data.commands);
  });

  socket.on("command", (data) => {
    socket.broadcast.emit("command", data);
  });
});

http.listen(3000, () => {
  console.log("listening on *:3000");
});
