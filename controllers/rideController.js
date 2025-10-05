import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';
import { UnauthenticatedError, BadRequestError } from '../errors/index.js';
import axios from 'axios';

const prisma = new PrismaClient();

const calculateFareEstimates = (distanceInKm) => {
  const vehicleTypes = [
    { name: 'Go Non AC', category: 'base', description: 'Everyday affordable rides', capacity: 4 },
    { name: 'Orventus Go', category: 'base', description: 'Affordable compact AC rides', capacity: 4 },
    { name: 'Premier', category: 'midrange', description: 'Comfortable sedans, top-quality drivers', capacity: 4 },
    { name: 'XL+ (Innova)', category: 'premium', description: 'Spacious, Comfortable Innovas', capacity: 6 },
    { name: 'Orventus Pet', category: 'midrange', description: 'Ride with your furry friend', capacity: 4 },
  ];
  const calculateFare = (category, distance) => {
    let baseFare = 0, perKmRate = 0; const baseDistance = 4;
    switch (category) {
      case 'midrange': baseFare = 115; perKmRate = 28; break;
      case 'premium': baseFare = 130; perKmRate = 32; break;
      default: baseFare = 100; perKmRate = 24; break;
    }
    if (distance <= baseDistance) return baseFare;
    const totalFare = baseFare + ((distance - baseDistance) * perKmRate);
    return parseFloat(totalFare.toFixed(2));
  };
  return vehicleTypes.map(vehicle => {
    const fare = calculateFare(vehicle.category, distanceInKm);
    return {  vehicle: vehicle.name, 
      description: vehicle.description,
      capacity: vehicle.capacity,
      distance: distanceInKm, 
      fare  };
  });
};

const emitRideUpdate = (req, ride) => {
  const eventName = `ride-update-${ride.id}`;
  req.io.emit(eventName, ride);
};

export const getRideEstimates = async (req, res) => {
  // This version uses a simulated distance
  const distanceInKm = parseFloat((Math.random() * 20 + 2).toFixed(2));
  const estimates = calculateFareEstimates(distanceInKm);
  res.status(StatusCodes.OK).json({ estimates });
};

export const initiateRide = async (req, res) => {
  const { pickupPlaceId, dropoffPlaceId } = req.body;
  if (!pickupPlaceId || !dropoffPlaceId) {
    throw new BadRequestError('Pickup and Dropoff locations are required.');
  }
  const apiKey = process.env.GOOGLE_API_KEY;
  const url = `https://maps.googleapis.com/maps/api/directions/json`;
  try {
    const response = await axios.get(url, {
      params: { origin: `place_id:${pickupPlaceId}`, destination: `place_id:${dropoffPlaceId}`, key: apiKey },
    });
    if (response.data.status !== 'OK' || !response.data.routes || response.data.routes.length === 0) {
      throw new Error(response.data.error_message || 'No route found');
    }
    const route = response.data.routes[0];
    const leg = route.legs[0];
    const distanceInKm = leg.distance.value / 1000;
    const estimates = calculateFareEstimates(distanceInKm);
    res.status(StatusCodes.OK).json({
      estimates,
      distance: leg.distance.text,
      duration: leg.duration.text,
      startLocation: leg.start_location,
      endLocation: leg.end_location,
      polyline: route.overview_polyline.points,
    });
  } catch (error) {
    console.error('Directions API Error:', error);
    throw new BadRequestError('Could not calculate route. Please try different locations.');
  }
};


export const getMyRides = async (req, res) => {
  const { id: userId } = req.user;
  const rides = await prisma.ride.findMany({
    where: { OR: [{ customerId: userId }, { riderId: userId }] },
    include: {
      customer: { select: { name: true, profilePictureUrl: true } },
      rider: { select: { name: true, profilePictureUrl: true } },
    },
    orderBy: { createdAt: 'desc' },
  });
  res.status(StatusCodes.OK).json({ rides });
};

export const createRide = async (req, res) => {
  const { id: userId } = req.user;
  const { pickupAddress, dropAddress, vehicle, fare } = req.body;
  const distance = parseFloat((Math.random() * 15 + 5).toFixed(2));
  const newRide = await prisma.ride.create({
    data: {
      pickupAddress, dropAddress, vehicle, fare, distance,
      customerId: userId,
      pickupLatitude: 12.9716, pickupLongitude: 77.5946,
      dropLatitude: 12.9716, dropLongitude: 77.5946,
    },
  });
  res.status(StatusCodes.CREATED).json({ ride: newRide });
};

export const getAvailableRides = async (req, res) => {
  const availableRides = await prisma.ride.findMany({
    where: { status: 'SEARCHING_FOR_RIDER' },
    orderBy: { createdAt: 'desc' },
  });
  res.status(StatusCodes.OK).json({ rides: availableRides });
};

export const acceptRide = async (req, res) => {
  const { id: riderId } = req.user;
  const { id: rideId } = req.params;
  const ride = await prisma.ride.update({
    where: { id: parseInt(rideId), status: 'SEARCHING_FOR_RIDER' },
    data: { riderId, status: 'ACCEPTED' },
  });
  
  emitRideUpdate(req, ride); // CRITICAL: Notify the customer
  
  res.status(StatusCodes.OK).json({ message: 'Ride accepted successfully', ride });
};

export const updateRideStatus = async (req, res) => {
  const { id: riderId } = req.user;
  const { id: rideId } = req.params;
  const { status } = req.body;
  if (!status || !['PICKED_UP', 'COMPLETED'].includes(status)) {
    throw new BadRequestError('Please provide a valid status.');
  }
  const ride = await prisma.ride.findUnique({ where: { id: parseInt(rideId) } });
  if (!ride) throw new BadRequestError(`No ride found with id ${rideId}`);
  if (ride.riderId !== riderId) throw new UnauthenticatedError('You are not authorized to update this ride.');
  if (status === 'COMPLETED' && ride.status !== 'PICKED_UP') {
    throw new BadRequestError('Cannot complete a ride before picking up the passenger.');
  }
   const updatedRide = await prisma.ride.update({ where: { id: parseInt(rideId) }, data: { status } });

  emitRideUpdate(req, updatedRide); // CRITICAL: Notify the customer

  res.status(StatusCodes.OK).json({ message: 'Ride status updated', ride: updatedRide });
};

// --- THIS IS THE MISSING FUNCTION ---
export const getAllRides = async (req, res) => {
  // TODO: This should be protected for ADMIN users only in the future
  const rides = await prisma.ride.findMany();
  res.status(StatusCodes.OK).json({ rides });
};

// Add this new function to controllers/rideController.js



// Add this new function to controllers/rideController.js

export const getRoutePolyline = async (req, res) => {
  const { startLat, startLng, endLat, endLng } = req.query;
  if (!startLat || !startLng || !endLat || !endLng) {
    throw new BadRequestError('Start and end coordinates are required.');
  }

  const apiKey = process.env.GOOGLE_API_KEY;
  const url = `https://maps.googleapis.com/maps/api/directions/json`;
  try {
    const response = await axios.get(url, {
      params: {
        origin: `${startLat},${startLng}`,
        destination: `${endLat},${endLng}`,
        key: apiKey,
      },
    });
    if (response.data.status !== 'OK' || !response.data.routes[0]) {
      throw new Error('No route found from Google');
    }
    const route = response.data.routes[0];
    const leg = route.legs[0]; // The first leg of the journey


    res.status(StatusCodes.OK).json({
      polyline: route.overview_polyline.points,
      duration: leg.duration.text, // e.g., "15 mins"
    });  
  } catch (error) {
    throw new BadRequestError('Could not calculate route.');
  }
};

