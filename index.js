// index.js (Final Version with Heartbeat Fix)

import dotenv from 'dotenv';
import express from 'express';
import http from 'http';
import { Server as socketIo } from 'socket.io';
import cookieParser from 'cookie-parser';
import cors from 'cors';

// --- IMPORT YOUR MIDDLEWARE & ROUTERS ---
import notFoundMiddleware from './middleware/not-found.js';
import errorHandlerMiddleware from './middleware/error-handler.js';
import authRoutes from './routes/authRoutes.js';
import rideRoutes from './routes/rideRoutes.js';
import userRoutes from './routes/userRoutes.js';

dotenv.config();

const app = express();
const server = http.createServer(app);

// Use a variable for your frontend URL to keep it clean
const frontendURL = 'http://localhost:53894'; // (Verify your port)

const io = new socketIo(server, {
  cors: {
    origin: frontendURL,
    methods: ["GET", "POST"],
    credentials: true
  },
  // This heartbeat ensures the connection stays alive through idle periods
  pingInterval: 10000, // Send a ping every 10 seconds
  pingTimeout: 5000,   // Wait 5 seconds for a pong response
});

app.use(cors({
  origin: frontendURL,
  credentials: true
}));

app.use(express.json());
app.use(cookieParser());
app.use(express.static('public'));

app.use((req, res, next) => {
  req.io = io;
  return next();
});

app.use('/auth', authRoutes);
app.use('/rides', rideRoutes);
app.use('/api/v1/users', userRoutes);

app.use(notFoundMiddleware);
app.use(errorHandlerMiddleware);

io.on('connection', (socket) => {
  console.log(`--- WebSocket Client Connected: ${socket.id} ---`);
  socket.on('disconnect', (reason) => {
    console.log(`--- WebSocket Client Disconnected: ${socket.id}, Reason: ${reason} ---`);
  });
});

const PORT = process.env.PORT || 3000;

const start = async () => {
  try {
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`HTTP server is running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.log(error);
  }
};

start();