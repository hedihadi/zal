const http = require('http');
const socketIo = require('socket.io');

// Get the port from the command line arguments or default to 4920
const PORT = process.argv[2] || 4920;
const NAME = process.argv[3] || 'Default Computer';

const server = http.createServer((req, res) => {
  // Handle HTTP requests
  if (req.method === 'GET' && req.url === '/') {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    res.end(`{"name":"${NAME}","server":"Zal"}`);
  }
});

const io = socketIo(server);

// Track the number of connected clients
let clients = [];

io.on('connect', (socket) => {
  console.log(`user connected, ${clients.length}`);
  // add client to the list of clients
  let client = { 'name': socket.handshake.query.name, 'type': socket.handshake.query.type, 'id': socket.id }
  clients.push(client)
  // Broadcast the updated client count
  io.emit('room_clients', clients);

  // Relay any event received to all clients except the sender
  socket.onAny((event, ...args) => {
    socket.broadcast.emit(event, ...args);
  });

  socket.on('disconnect', () => {
    console.log(`user disconnected, ${clients.length}`);
    // remove the disconnected client
    clients = clients.filter(client => client.id !== socket.id);
    // Broadcast the updated client count
    io.emit('room_clients', clients);
  });
});

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});