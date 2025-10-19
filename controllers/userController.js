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

export const getAllUsers = async (req, res) => {
  // We will add role-based protection for this later. For now, any logged-in user can access.
  const users = await prisma.user.findMany({
    // Select only the fields that are safe to send to the frontend
    select: {
      id: true,
      name: true,
      phone: true,
      role: true,
      profilePictureUrl: true,
      createdAt: true,
    },
    orderBy: {
      createdAt: 'desc',
    },
  });
  res.status(StatusCodes.OK).json({ users });
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

export const updateUserStatus = async (req, res) => {
  const { id: userId } = req.params; // Get user ID from the URL
  const { isActive } = req.body; // Get the new status from the request body

  if (typeof isActive !== 'boolean') {
    throw new BadRequestError('isActive must be a boolean value.');
  }

  const updatedUser = await prisma.user.update({
    where: { id: parseInt(userId) },
    data: { isActive },
  });

  res.status(StatusCodes.OK).json({ msg: 'User status updated', user: updatedUser });
};