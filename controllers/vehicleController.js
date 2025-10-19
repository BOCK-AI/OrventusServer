import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError } from '../errors/index.js';

const prisma = new PrismaClient();

// GET /api/v1/vehicles
export const getAllVehicles = async (req, res) => {
  const vehicles = await prisma.vehicle.findMany({
    orderBy: { createdAt: 'asc' },
  });
  res.status(StatusCodes.OK).json({ vehicles });
};

// POST /api/v1/vehicles
export const createVehicle = async (req, res) => {
  const { name, costPerKm, icon } = req.body;
  if (!name || !costPerKm || !icon) {
    throw new BadRequestError('Please provide name, costPerKm, and icon');
  }
  const newVehicle = await prisma.vehicle.create({
    data: { 
      name,
      costPerKm: parseFloat(costPerKm),
      icon 
    },
  });
  res.status(StatusCodes.CREATED).json({ vehicle: newVehicle });
};

// PATCH /api/v1/vehicles/:id
export const updateVehicle = async (req, res) => {
  const { id } = req.params;
  const { name, costPerKm, icon, isActive } = req.body;
  const updatedVehicle = await prisma.vehicle.update({
    where: { id: parseInt(id) },
    data: { 
      name, 
      costPerKm: parseFloat(costPerKm), 
      icon, 
      isActive 
    },
  });
  res.status(StatusCodes.OK).json({ vehicle: updatedVehicle });
};

// DELETE /api/v1/vehicles/:id
export const deleteVehicle = async (req, res) => {
  const { id } = req.params;
  await prisma.vehicle.delete({
    where: { id: parseInt(id) },
  });
  res.status(StatusCodes.OK).json({ msg: 'Success! Vehicle removed.' });
};