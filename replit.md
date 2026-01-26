# replit.md

## Overview
This is a web-based terminal application called "SANTRIX CYBERSECURITY HUB". It provides a real terminal interface for cybersecurity testing and auditing.

## User Preferences
- **COMMUNICATION STYLE:** Simple, everyday language.
- **DEVELOPMENT PREFERENCE:** ALWAYS use real code, real scripts, and functional tools. NEVER use mock data, simulations, placeholders, or "educational examples" that don't execute real commands. Every feature added must be functional and connected to the backend terminal or system.
- **GITHUB EXPORT:** Ensure that all tools and scripts remain functional and "real" after export.

## System Architecture
### Frontend Architecture
- **Static HTML/CSS/JS** in `public/`
- **xterm.js** for the terminal UI
- **Socket.IO client** for real-time I/O

### Backend Architecture
- **Express.js** web server
- **Socket.IO** for WebSocket communication
- **node-pty** to manage real shell processes

## Recent Changes
- Added "Fintech Security" category to the menu.
- Implemented `scripts/payment_bypass.sh` for real-world payment gateway auditing (security headers, parameter manipulation, and webhook scanning).
- Updated `public/index.html` to execute real shell commands via the terminal.
