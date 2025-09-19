import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

const prisma = new PrismaClient();

export const getMyProfile = async (req, res) => {
  // req.user is attached by the authenticateUser middleware
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
  });
  // We don't want to send back sensitive info, even if it's null
  delete user.otp;
  delete user.otpExpiry;
  res.status(StatusCodes.OK).json({ user });
};

// Add this new function to controllers/userController.js

export const updateMyProfile = async (req, res) => {
  const { id: userId } = req.user;
  const { name } = req.body; // For now, we'll just update the name

  if (!name) {
    throw new BadRequestError('Name field cannot be empty.');
  }

  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: { name },
  });

  // Clean up sensitive data before sending back
  delete updatedUser.otp;
  delete updatedUser.otpExpiry;

  res.status(StatusCodes.OK).json({ msg: 'Profile updated successfully', user: updatedUser });
};