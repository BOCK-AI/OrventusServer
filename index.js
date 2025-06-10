import dotenv from 'dotenv';
import EventEmitter from 'events';
import express from 'express';
import http from 'http';
import { Server as socketIo } from 'socket.io';
import notFoundMiddleware from './errors/not-found.js';
import errorHandlerMiddleware from './errors/custom-api.js';
// Routers
import authRoutes from './routes/authRoutes.js';
import rideRoutes from './routes/rideRoutes.js';
// Import socket handler
import handleSocketConnection from './controllers/sockets.js';

dotenv.config();
EventEmitter.defaultMaxListeners = 20;

const app = express();
app.use(express.json());

const server = http.createServer(app);
const io = new socketIo(server, { cors: { origin: '*' } });

// Attach the WebSocket instance to the request object
app.use((req, res, next) => {
  req.io = io;
  return next();
});

// Initialize the WebSocket handling logic
handleSocketConnection(io);

// Routes
app.use('/auth', authRoutes);
app.use('/rides', rideRoutes);

// Middleware
app.use(notFoundMiddleware);
app.use(errorHandlerMiddleware);

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
