import dotenv from 'dotenv';
import express from 'express';
import http from 'http';
import { Server as socketIo } from 'socket.io';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import { PrismaClient } from '@prisma/client'; // Import PrismaClient

// --- IMPORT YOUR MIDDLEWARE & ROUTERS ---
import notFoundMiddleware from './middleware/not-found.js';
import errorHandlerMiddleware from './middleware/error-handler.js';
import authRoutes from './routes/authRoutes.js';
import rideRoutes from './routes/rideRoutes.js';
import userRoutes from './routes/userRoutes.js';
import miscRoutes from './routes/miscRoutes.js';

// --- INITIAL CONFIGURATION ---
dotenv.config();
const prisma = new PrismaClient(); // Create an instance of PrismaClient


const app = express();
const server = http.createServer(app);
const frontendURL = 'http://localhost:54243'; // UPDATE THIS PORT IF YOURS IS DIFFERENT

const io = new socketIo(server, {
  cors: {
    origin: frontendURL,
    methods: ["GET", "POST"],
    credentials: true
  },
  allowEIO3: true,

  pingInterval: 10000,
  pingTimeout: 5000,
});

// --- MIDDLEWARE SETUP ---
app.use(cors({ origin: frontendURL, credentials: true }));
app.use(express.json());
app.use(cookieParser());
app.use((req, res, next) => {
  req.io = io;
  return next();
});

// --- API ROUTES ---
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/rides', rideRoutes);
app.use('/api/v1/misc', miscRoutes);

// --- ERROR HANDLING MIDDLEWARE ---
app.use(notFoundMiddleware);
app.use(errorHandlerMiddleware);

// --- REAL-TIME WEBSOCKET LOGIC ---
io.on('connection', (socket) => {
  console.log(`--- WebSocket Client Connected: ${socket.id} ---`);

  // --- THIS IS THE NEW LOGIC ---
  // Listen for the location update event from the rider's app
  socket.on('rider-location-update', async (data) => {
    const { rideId, lat, lng } = data;
    if (!rideId || lat == null || lng == null) return;
    
    console.log(`Received location for ride ${rideId}: ${lat}, ${lng}`);

    try {
      // Find the ride to get the customer's ID
      const ride = await prisma.ride.findUnique({ where: { id: rideId } });

      if (ride) {
        // Create a unique event name to send ONLY to the correct customer
        const customerEventName = `ride-location-update-${ride.id}`;
        
        // Emit the location data to the customer
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

// --- SERVER INITIALIZATION ---
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`HTTP server is running on http://localhost:${PORT}`);
});