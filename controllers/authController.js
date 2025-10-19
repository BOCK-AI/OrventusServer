import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError, UnauthenticatedError } from '../errors/index.js';
import jwt from 'jsonwebtoken';

const prisma = new PrismaClient();

function createAccessToken(user) {
  return jwt.sign({ id: user.id, role: user.role }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: '15m' });
}
function createRefreshToken(user) {
  return jwt.sign({ id: user.id, role: user.role }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '7d' });
}

export const loginOrRegister = async (req, res) => {
  try {
    const { phone, name, role } = req.body;
    if (!phone || !role) {
      throw new BadRequestError('Phone number and role are required');
    }

    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000);

    const user = await prisma.user.upsert({
      where: { phone },
      update: { otp, otpExpiry },
      create: { phone, name: name || 'Admin', role, otp, otpExpiry },
    });

    console.log(`--- OTP for user ${user.phone}: ${otp} ---`);
    res.status(StatusCodes.OK).json({ msg: 'OTP sent successfully. Please verify.' });

  } catch (error) {
    console.error("--- CRASH IN loginOrRegister ---", error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: error.message || 'An internal server error occurred' });
  }
};

export const verifyOtp = async (req, res) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      throw new BadRequestError('Phone number and OTP are required');
    }
    const user = await prisma.user.findUnique({ where: { phone } });
    if (!user) throw new UnauthenticatedError('Invalid credentials');
    if (user.otp !== otp) throw new UnauthenticatedError('Invalid OTP');
    if (new Date() > user.otpExpiry) throw new UnauthenticatedError('OTP has expired');

    const accessToken = createAccessToken(user);
    const refreshTokenValue = createRefreshToken(user);
    await prisma.refreshToken.create({
      data: { token: refreshTokenValue, userId: user.id },
    });
    await prisma.user.update({
      where: { phone },
      data: { otp: null, otpExpiry: null },
    });
    res.status(StatusCodes.OK).json({
      msg: 'User logged in successfully',
      user,
      accessToken,
      refreshToken: refreshTokenValue,
    });
  } catch (error) {
    console.error("--- CRASH IN verifyOtp ---", error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: error.message || 'An internal server error occurred' });
  }
};