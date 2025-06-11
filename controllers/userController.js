import { PrismaClient } from '../generated/prisma/index.js';
import jwt from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError, UnauthenticatedError } from '../errors/index.js';

const prisma = new PrismaClient();

function createAccessToken(user) {
  return jwt.sign(
    { id: user.id, phone: user.phone },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: process.env.ACCESS_TOKEN_EXPIRY }
  );
}

function createRefreshToken(user) {
  return jwt.sign(
    { id: user.id, phone: user.phone },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY }
  );
}

export const auth = async (req, res) => {
  const { phone, role } = req.body;

  if (!phone) {
    throw new BadRequestError('Phone number is required');
  }

  if (!role || !['customer', 'rider'].includes(role)) {
    throw new BadRequestError('Valid role is required (customer or rider)');
  }

  try {
    let user = await prisma.user.findUnique({ where: { phone } });

    if (user) {
      if (user.role !== role) {
        throw new BadRequestError('Phone number and role do not match');
      }
      const accessToken = createAccessToken(user);
      const refreshToken = createRefreshToken(user);
      return res.status(StatusCodes.OK).json({
        message: 'User logged in successfully',
        user,
        access_token: accessToken,
        refresh_token: refreshToken,
      });
    }

    user = await prisma.user.create({ data: { phone, role } });
    const accessToken = createAccessToken(user);
    const refreshToken = createRefreshToken(user);
    res.status(StatusCodes.CREATED).json({
      message: 'User created successfully',
      user,
      access_token: accessToken,
      refresh_token: refreshToken,
    });
  } catch (error) {
    console.error(error);
    throw error;
  }
};

export const refreshToken = async (req, res) => {
  const { refresh_token } = req.body;
  if (!refresh_token) {
    throw new BadRequestError('Refresh token is required');
  }
  try {
    const payload = jwt.verify(refresh_token, process.env.REFRESH_TOKEN_SECRET);
    const user = await prisma.user.findUnique({ where: { id: payload.id } });
    if (!user) {
      throw new UnauthenticatedError('Invalid refresh token');
    }
    const newAccessToken = createAccessToken(user);
    const newRefreshToken = createRefreshToken(user);
    res.status(StatusCodes.OK).json({
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
    });
  } catch (error) {
    console.error(error);
    throw new UnauthenticatedError('Invalid refresh token');
  }
};
