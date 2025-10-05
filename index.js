// index.js (The Final, Correct Version)
import dotenv from 'dotenv';
import express from 'express';
import http from 'http';
import { Server as socketIo } from 'socket.io';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';

import notFoundMiddleware from './middleware/not-found.js';
import errorHandlerMiddleware from './middleware/error-handler.js';
import authRoutes from './routes/authRoutes.js';
import rideRoutes from './routes/rideRoutes.js';
import userRoutes from './routes/userRoutes.js';
import miscRoutes from './routes/miscRoutes.js';

dotenv.config();
const prisma = new PrismaClient();

const app = express();
const server = http.createServer(app);

const frontendURL_dev = 'http://localhost:55136'; // Make sure this port is correct
const frontendURL_prod = 'https://orventus-472112.web.app/'; // Your new Firebase URL

const allowedOrigins = [frontendURL_dev, frontendURL_prod];


const io = new socketIo(server, {
  cors: { origin: allowedOrigins, // Use the array here
    methods: ["GET", "POST"],
    credentials: true },
  allowEIO3: true,
  pingInterval: 10000,
  pingTimeout: 5000,
});

app.use(cors({
   origin: allowedOrigins, 
   credentials: true 
  }));
app.use(express.json());
app.use(cookieParser());
app.use((req, res, next) => { req.io = io; return next(); });

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/rides', rideRoutes);
app.use('/api/v1/misc', miscRoutes);

app.use(notFoundMiddleware);
app.use(errorHandlerMiddleware);

// --- THIS IS THE FINAL, CORRECTED WEBSOCKET LOGIC ---
io.on('connection', (socket) => {
  console.log(`--- WebSocket Client Connected: ${socket.id} ---`);

  socket.on('rider-location-update', async (data) => {
    const { rideId, lat, lng } = data;
    if (!rideId || lat == null || lng == null) return;
    
    try {
      const ride = await prisma.ride.findUnique({ where: { id: rideId } });
      if (ride) {
        const customerEventName = `ride-location-update-${ride.id}`;
        // Log before emitting to be sure
        console.log(`--- Relaying location for ride ${rideId} to customer on event '${customerEventName}' ---`);
        io.emit(customerEventName, { lat, lng });
      }
    } catch (error) {
      console.error(`Error relaying location for ride ${rideId}:`, error);
    }
  });

  socket.on('disconnect', (reason) => {
    console.log(`--- WebSocket Client Disconnected: ${socket.id}, Reason: ${reason} ---`);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`HTTP server is running on http://localhost:${PORT}`);
});