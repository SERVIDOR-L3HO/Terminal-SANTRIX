# replit.md

## Overview

This is a web-based terminal application called "SANTRIX CYBERSECURITY HUB". It provides a browser-accessible terminal interface that connects to a real shell session on the server. Users can interact with a full terminal environment directly from their web browser, making it suitable for remote shell access, educational purposes, or cybersecurity training environments.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture
- **Static HTML/CSS/JS** served from the `public/` directory
- **xterm.js** (v5.3.0) provides the terminal UI component in the browser
- **xterm-addon-fit** handles responsive terminal sizing
- **Socket.IO client** manages real-time communication with the server
- **Styling**: Custom cybersecurity-themed dark UI with JetBrains Mono font, green accent colors

### Backend Architecture
- **Express.js** (v5.x) serves as the web server framework
- **Node.js** runtime with a single entry point (`server.js`)
- **Socket.IO** (v4.x) handles WebSocket connections for real-time terminal I/O
- **node-pty** spawns and manages pseudo-terminal processes on the server

### Real-time Communication Flow
1. Client connects via Socket.IO
2. Server spawns a new PTY process (bash or system default shell)
3. Bidirectional data flow:
   - `input` event: Client keystrokes → Server PTY
   - `output` event: Server PTY output → Client terminal
   - `resize` event: Client terminal resize → Server PTY resize
4. On disconnect, PTY process is killed

### Server Configuration
- Runs on port 5000
- Binds to all interfaces (0.0.0.0)
- Uses environment's default shell (`$SHELL` or falls back to `bash`)
- PTY initialized with 80 columns × 24 rows

## External Dependencies

### NPM Packages
| Package | Purpose |
|---------|---------|
| express | Web server and static file serving |
| socket.io | WebSocket-based real-time communication |
| node-pty | Native pseudo-terminal bindings for Node.js |
| xterm | Terminal emulator UI (client-side) |
| xterm-addon-fit | Terminal resizing addon |

### CDN Resources
- xterm CSS: `cdn.jsdelivr.net/npm/xterm@5.3.0/css/xterm.min.css`
- Google Fonts: JetBrains Mono font family

### System Dependencies
- Requires a Unix-like shell environment (bash or system shell)
- node-pty requires native compilation (may need build tools on some systems)

### No Database
This application is stateless and does not use any database or persistent storage.