import { PrismaClient } from '../generated/prisma/index.js';
import jwt from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError, UnauthenticatedError } from '../errors/index.js';

const prisma = new PrismaClient();

// Helper function to create a short-lived access token
function createAccessToken(user) {
  return jwt.sign(
    { id: user.id, phone: user.phone },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: process.env.ACCESS_TOKEN_EXPIRY }
  );
}

// Helper function to create a long-lived refresh token
function createRefreshToken(user) {
  return jwt.sign(
    { id: user.id, phone: user.phone },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY }
  );
}

// Handles both user registration and login, setting a secure httpOnly cookie
export const auth = async (req, res) => {
  const { phone, role } = req.body;

  if (!phone) throw new BadRequestError('Phone number is required');
  if (!role || !['customer', 'rider'].includes(role)) {
    throw new BadRequestError('Valid role is required (customer or rider)');
  }

  const existingUser = await prisma.user.findUnique({ where: { phone } });

  if (existingUser && existingUser.role !== role) {
    throw new BadRequestError('Phone number and role do not match');
  }

  const user = existingUser || (await prisma.user.create({ data: { phone, role } }));

  const accessToken = createAccessToken(user);
  const refreshTokenValue = createRefreshToken(user);

  await prisma.refreshToken.create({
    data: {
      token: refreshTokenValue,
      userId: user.id,
    },
  });

  res.cookie('refreshToken', refreshTokenValue, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    signed: false,
    expires: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    sameSite: 'strict',
  });

  res.status(existingUser ? StatusCodes.OK : StatusCodes.CREATED).json({
    message: existingUser ? 'User logged in successfully' : 'User created successfully',
    user,
    access_token: accessToken,
  });
};

// Handles securely refreshing the user's session by reading from the cookie
export const refreshToken = async (req, res) => {
  const refresh_token = req.cookies.refreshToken;

  if (!refresh_token) {
    throw new BadRequestError('Refresh token is required');
  }

  const existingToken = await prisma.refreshToken.findUnique({
    where: { token: refresh_token },
  });

  if (!existingToken || !existingToken.isValid) {
    throw new UnauthenticatedError('Invalid refresh token');
  }

  try {
    const payload = jwt.verify(refresh_token, process.env.REFRESH_TOKEN_SECRET);

    await prisma.refreshToken.update({
      where: { id: existingToken.id },
      data: { isValid: false },
    });

    const user = { id: payload.id, phone: payload.phone };
    const newAccessToken = createAccessToken(user);
    const newRefreshTokenValue = createRefreshToken(user);

    await prisma.refreshToken.create({
      data: {
        token: newRefreshTokenValue,
        userId: user.id,
      },
    });

    res.cookie('refreshToken', newRefreshTokenValue, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        signed: false,
        expires: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        sameSite: 'strict',
    });
    
    res.status(StatusCodes.OK).json({
      access_token: newAccessToken,
    });

  } catch (error) {
    throw new UnauthenticatedError('Invalid or expired refresh token');
  }
};

// Invalidates the user's session on the server and clears the client's cookie
export const logout = async (req, res) => {
  const refreshToken = req.cookies.refreshToken;

  if (refreshToken) {
    await prisma.refreshToken.updateMany({
      where: { token: refreshToken },
      data: { isValid: false },
    });
  }

  res.clearCookie('refreshToken', {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
  });

  res.status(StatusCodes.OK).json({ msg: 'User logged out successfully!' });
};


// Fetches the profile of the currently authenticated user
export const getMe = async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
  });

  res.status(StatusCodes.OK).json({ user });
};