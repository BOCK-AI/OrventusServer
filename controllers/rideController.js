// controllers/rideController.js

import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';
import { UnauthenticatedError, BadRequestError } from '../errors/index.js';

const prisma = new PrismaClient();

const emitRideUpdate = (req, ride) => {
  const eventName = `ride-update-${ride.id}`;
  console.log(`--- Emitting WebSocket event: '${eventName}' ---`);
  req.io.emit(eventName, ride);
};

// --- THIS IS THE NEW FUNCTION ---
// Calculates fare estimates for different vehicle types
export const getRideEstimates = async (req, res) => {
  const { pickupAddress, dropAddress } = req.body;

  // In a real app, you would use a service like Google Maps Distance Matrix API here.
  // For now, we'll simulate it with a random distance.
  const distanceInKm = parseFloat((Math.random() * 15 + 5).toFixed(2)); // Random distance between 5 and 20 km

  const vehicleRates = {
    bike: 10,   // $10 per km
    auto: 15,   // $15 per km
    cab: 20,    // $20 per km
    premium: 30 // $30 per km
  };

  const estimates = Object.keys(vehicleRates).map(vehicle => {
    const rate = vehicleRates[vehicle];
    const fare = parseFloat((rate * distanceInKm).toFixed(2));
    return { vehicle, distance: distanceInKm, fare };
  });

  res.status(StatusCodes.OK).json({ estimates });
};
// In controllers/rideController.js

export const createRide = async (req, res) => {
  const { id: userId } = req.user;
  
  // --- THIS IS THE KEY CHANGE ---
  // Get vehicle and fare from the request body, not hardcoded values
  const {
    pickupAddress,
    dropAddress,
    vehicle,
    fare
  } = req.body;

  // In a real app, you would also get distance and coordinates
  // For now, we'll keep those hardcoded.
  const distance = parseFloat((Math.random() * 15 + 5).toFixed(2));

  const newRide = await prisma.ride.create({
    data: {
      pickupAddress,
      dropAddress,
      customerId: userId,
      vehicle, // Use the value from the frontend
      fare,    // Use the value from the frontend
      distance,
      // Keep these hardcoded for now
      pickupLatitude: 12.9716,
      pickupLongitude: 77.5946,
      dropLatitude: 12.9716,
      dropLongitude: 77.5946,
    },
  });

  res.status(StatusCodes.CREATED).json({ ride: newRide });
};

// --- EXISTING FUNCTIONS (Unchanged) ---
export const getMyRides = async (req, res) => { /* ... existing code ... */ };
//export const createRide = async (req, res) => { /* ... existing code ... */ };
export const getAvailableRides = async (req, res) => { /* ... existing code ... */ };
export const acceptRide = async (req, res) => { /* ... existing code ... */ };
export const updateRideStatus = async (req, res) => { /* ... existing code ... */ };
export const getAllRides = async (req, res) => { /* ... existing code ... */ };