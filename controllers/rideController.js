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
  // In a real app, you would get this from a mapping service like Google Maps Distance Matrix API.
  // For now, we'll continue to simulate it with a random distance.
  const distanceInKm = parseFloat((Math.random() * 20 + 2).toFixed(2)); // Random distance between 2 and 22 km

  // --- NEW: Define our cab types with their properties ---
  const vehicleTypes = [
    {
      name: 'Go Non AC',
      category: 'upto10lakh',
      description: 'Everyday affordable rides',
      capacity: 4,
    },
    {
      name: 'Orventus Go',
      category: 'upto10lakh', // Assuming this is also in the base category
      description: 'Affordable compact AC rides',
      capacity: 4,
    },
    {
      name: 'Premier',
      category: '10to15lakh',
      description: 'Comfortable sedans, top-quality drivers',
      capacity: 4,
    },
    {
      name: 'XL+ (Innova)',
      category: 'above15lakh',
      description: 'Spacious, Comfortable Innovas',
      capacity: 6,
    },
     {
      name: 'Orventus Pet',
      category: '10to15lakh', // Assuming a mid-range cost for this service
      description: 'Ride with your furry friend',
      capacity: 4,
    },
  ];

  // --- NEW: The Fare Calculation Logic based on your rules ---
  const calculateFare = (category, distance) => {
    let baseFare = 0;
    let baseDistance = 4; // km
    let perKmRate = 0;

    switch (category) {
      case '10to15lakh':
        baseFare = 115;
        perKmRate = 28;
        break;
      case 'above15lakh':
        baseFare = 130;
        perKmRate = 32;
        break;
      case 'upto10lakh':
      default:
        baseFare = 100;
        perKmRate = 24;
        break;
    }

    if (distance <= baseDistance) {
      return baseFare;
    } else {
      const additionalDistance = distance - baseDistance;
      const totalFare = baseFare + (additionalDistance * perKmRate);
      return parseFloat(totalFare.toFixed(2));
    }
  };

  // --- NEW: Generate the estimates using the new logic ---
  const estimates = vehicleTypes.map(vehicle => {
    const fare = calculateFare(vehicle.category, distanceInKm);
    return {
      vehicle: vehicle.name,
      description: vehicle.description,
      capacity: vehicle.capacity,
      distance: distanceInKm,
      fare: fare,
    };
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

// In controllers/rideController.js

export const getMyRides = async (req, res) => {
  const { id: userId } = req.user;

  const rides = await prisma.ride.findMany({
    where: {
      OR: [{ customerId: userId }, { riderId: userId }],
    },
    // --- THIS IS THE KEY CHANGE ---
    // Also include the full User object for the customer and rider
    include: {
      customer: {
        select: { name: true, profilePictureUrl: true }, // Only select the fields we need
      },
      rider: {
        select: { name: true, profilePictureUrl: true },
      },
    },
    // --- END CHANGE ---
    orderBy: {
      createdAt: 'desc',
    },
  });

  res.status(StatusCodes.OK).json({ rides });
};

// --- EXISTING FUNCTIONS (Unchanged) ---
//export const createRide = async (req, res) => { /* ... existing code ... */ };
export const getAvailableRides = async (req, res) => { /* ... existing code ... */ };
export const acceptRide = async (req, res) => { /* ... existing code ... */ };
export const updateRideStatus = async (req, res) => { /* ... existing code ... */ };
export const getAllRides = async (req, res) => { /* ... existing code ... */ };