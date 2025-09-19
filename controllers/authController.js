// controllers/authController.js

import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError, UnauthenticatedError } from '../errors/index.js';
import jwt from 'jsonwebtoken'; // <-- NEW IMPORT for JWT

const prisma = new PrismaClient();

// --- JWT HELPER FUNCTIONS ---
// These create our access and refresh tokens
function createAccessToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: process.env.ACCESS_TOKEN_EXPIRY }
  );
}

function createRefreshToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY }
  );
}

// Handles the initial phone number submission and OTP generation
export const loginOrRegister = async (req, res) => {
  const { phone, name, role } = req.body;
  if (!phone || !role) {
    throw new BadRequestError('Phone number and role are required');
  }

  const otp = Math.floor(1000 + Math.random() * 9000).toString();
  const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes expiry

  const user = await prisma.user.upsert({
    where: { phone },
    update: { otp, otpExpiry },
    create: { phone, name, role, otp, otpExpiry },
  });

  console.log(`--- OTP for user ${user.phone}: ${otp} ---`);

  res.status(StatusCodes.OK).json({ msg: 'OTP sent successfully. Please verify.' });
};

// --- THIS IS THE NEW FUNCTION ---
// Verifies the OTP and returns JWTs if successful
export const verifyOtp = async (req, res) => {
  const { phone, otp } = req.body;
  if (!phone || !otp) {
    throw new BadRequestError('Phone number and OTP are required');
  }

  // 1. Find the user by their phone number
  const user = await prisma.user.findUnique({
    where: { phone },
  });

  // 2. Check if the user exists, if the OTP matches, and if it's not expired
  if (!user) {
    throw new UnauthenticatedError('Invalid credentials');
  }
  if (user.otp !== otp) {
    throw new UnauthenticatedError('Invalid OTP');
  }
  if (new Date() > user.otpExpiry) {
    throw new UnauthenticatedError('OTP has expired');
  }

  // 3. If everything is correct, generate the tokens
  const accessToken = createAccessToken(user);
  const refreshTokenValue = createRefreshToken(user);

  // 4. Save the refresh token to the database for our rotation strategy
  await prisma.refreshToken.create({
    data: {
      token: refreshTokenValue,
      userId: user.id,
    },
  });
  
  // 5. Clear the OTP from the database after it has been used
  await prisma.user.update({
    where: { phone },
    data: {
      otp: null,
      otpExpiry: null,
    },
  });

  // 6. Send the tokens back to the client
  res.status(StatusCodes.OK).json({
    msg: 'User logged in successfully',
    user,
    accessToken,
    refreshToken: refreshTokenValue,
  });
};