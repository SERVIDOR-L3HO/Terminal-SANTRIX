const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const pty = require('node-pty');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static('public'));

io.on('connection', (socket) => {
    const shell = process.env.SHELL || 'bash';
    const ptyProcess = pty.spawn(shell, [], {
        name: 'xterm-color',
        cols: 80,
        rows: 24,
        cwd: process.cwd(),
        env: process.env
    });

    ptyProcess.onData((data) => {
        socket.emit('output', data);
    });

    socket.on('input', (data) => {
        ptyProcess.write(data);
    });

    socket.on('resize', (size) => {
        ptyProcess.resize(size.cols, size.rows);
    });

    socket.on('disconnect', () => {
        ptyProcess.kill();
    });
});

const PORT = 5000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Terminal server running on port ${PORT}`);
});
