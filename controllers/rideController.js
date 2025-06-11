import { PrismaClient } from '../generated/prisma/index.js';
import { BadRequestError, NotFoundError } from '../errors/index.js';
import { StatusCodes } from 'http-status-codes';
import {
  calculateDistance,
  calculateFare,
  generateOTP,
} from '../utils/mapUtils.js';

const prisma = new PrismaClient();

export const createRide = async (req, res) => {
  const { vehicle, pickup, drop } = req.body;

  if (!vehicle || !pickup || !drop) {
    throw new BadRequestError('Vehicle, pickup, and drop details are required');
  }

  const {
    address: pickupAddress,
    latitude: pickupLat,
    longitude: pickupLon,
  } = pickup;
  const { address: dropAddress, latitude: dropLat, longitude: dropLon } = drop;

  if (!pickupAddress || pickupLat == null || pickupLon == null || !dropAddress || dropLat == null || dropLon == null) {
    throw new BadRequestError('Complete pickup and drop details are required');
  }

  const customer = req.user;

  try {
    const distance = calculateDistance(pickupLat, pickupLon, dropLat, dropLon);
    const fareObj = calculateFare(distance, vehicle);
    const fare = fareObj[vehicle];

    const ride = await prisma.ride.create({
      data: {
        vehicle,
        distance,
        fare,
        pickupAddress,
        pickupLatitude: pickupLat,
        pickupLongitude: pickupLon,
        dropAddress,
        dropLatitude: dropLat,
        dropLongitude: dropLon,
        customer: { connect: { id: customer.id } },
        otp: generateOTP(),
      },
      include: { customer: true, rider: true },
    });

    res.status(StatusCodes.CREATED).json({
      message: 'Ride created successfully',
      ride,
    });
  } catch (error) {
    console.error(error);
    throw new BadRequestError('Failed to create ride');
  }
};

export const acceptRide = async (req, res) => {
  const riderId = req.user.id;
  const { rideId } = req.params;

  if (!rideId) {
    throw new BadRequestError('Ride ID is required');
  }

  try {
    let ride = await prisma.ride.findUnique({
      where: { id: parseInt(rideId) },
      include: { customer: true },
    });

    if (!ride) {
      throw new NotFoundError('Ride not found');
    }

    if (ride.status !== 'SEARCHING_FOR_RIDER') {
      throw new BadRequestError('Ride is no longer available for assignment');
    }

    ride = await prisma.ride.update({
      where: { id: parseInt(rideId) },
      data: {
        rider: { connect: { id: riderId } },
        status: 'START',
      },
      include: { customer: true, rider: true },
    });

    if (req.socket) {
      req.socket.to(`ride_${rideId}`).emit('rideUpdate', ride);
      req.socket.to(`ride_${rideId}`).emit('rideAccepted');
    }

    res.status(StatusCodes.OK).json({
      message: 'Ride accepted successfully',
      ride,
    });
  } catch (error) {
    console.error('Error accepting ride:', error);
    throw new BadRequestError('Failed to accept ride');
  }
};

export const updateRideStatus = async (req, res) => {
  const { rideId } = req.params;
  const { status } = req.body;

  if (!rideId || !status) {
    throw new BadRequestError('Ride ID and status are required');
  }

  try {
    let ride = await prisma.ride.findUnique({
      where: { id: parseInt(rideId) },
      include: { customer: true, rider: true },
    });

    if (!ride) {
      throw new NotFoundError('Ride not found');
    }

    if (!['START', 'ARRIVED', 'COMPLETED'].includes(status)) {
      throw new BadRequestError('Invalid ride status');
    }

    ride = await prisma.ride.update({
      where: { id: parseInt(rideId) },
      data: { status },
      include: { customer: true, rider: true },
    });

    if (req.socket) {
      req.socket.to(`ride_${rideId}`).emit('rideUpdate', ride);
    }

    res.status(StatusCodes.OK).json({
      message: `Ride status updated to ${status}`,
      ride,
    });
  } catch (error) {
    console.error('Error updating ride status:', error);
    throw new BadRequestError('Failed to update ride status');
  }
};

export const getMyRides = async (req, res) => {
  const userId = req.user.id;
  const { status } = req.query;

  try {
    const where = {
      OR: [
        { customerId: userId },
        { riderId: userId },
      ],
    };
    if (status) {
      where.status = status;
    }
    const rides = await prisma.ride.findMany({
      where,
      include: {
        customer: { select: { id: true, phone: true, role: true } },
        rider: { select: { id: true, phone: true, role: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    res.status(StatusCodes.OK).json({
      message: 'Rides retrieved successfully',
      count: rides.length,
      rides,
    });
  } catch (error) {
    console.error('Error retrieving rides:', error);
    throw new BadRequestError('Failed to retrieve rides');
  }
};
