import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError, UnauthenticatedError } from '../errors/index.js';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

// Helper function to create a short-lived access token
function createAccessToken(user) {
  return jwt.sign(
    { id: user.id, role:user.role },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: process.env.ACCESS_TOKEN_EXPIRY }
  );
}

// Helper function to create a long-lived refresh token
function createRefreshToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY }
  );
}

// Handles both user registration and login, setting a secure httpOnly cookie
// Replace the old auth function in userController.js with this new one
// Replace the old auth function in userController.js with this new one

export const auth = async (req, res) => {
  const { email, password, role } = req.body;

  if (!email || !password || !role) {
    throw new BadRequestError('Please provide email, password, and role');
  }

  let user = await prisma.user.findUnique({ where: { email } });

  if (user) {
    // --- LOGIN LOGIC ---
    const isPasswordCorrect = await bcrypt.compare(password, user.password);
    if (!isPasswordCorrect) {
      throw new UnauthenticatedError('Invalid credentials');
    }
    // This is a subtle but important check. If the role doesn't match, reject.
    if (user.role !== role) {
       throw new UnauthenticatedError('A user with this email already exists with a different role.');
    }

  } else {
    // --- REGISTRATION LOGIC ---
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        role,
      },
    });
  }

  // --- CRITICAL CHANGE: TOKEN CREATION HAPPENS HERE, USING THE FINAL 'user' OBJECT ---
  // This 'user' object is guaranteed to be the correct, most up-to-date one.
  const accessToken = createAccessToken(user);
  const refreshTokenValue = createRefreshToken(user);

  await prisma.refreshToken.create({
    data: { token: refreshTokenValue, userId: user.id },
  });

  res.status(user ? StatusCodes.OK : StatusCodes.CREATED).json({
    message: user ? 'User logged in successfully' : 'User created successfully',
    user,
    access_token: accessToken,
    refresh_token: refreshTokenValue,
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
  console.log('--- REACHED getMe CONTROLLER ---'); // <-- ADD THIS

  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
  });

  res.status(StatusCodes.OK).json({ user });
};

// Add this new function inside controllers/userController.js

export const updateMe = async (req, res) => {
  // We only allow users to update their name and email
  const { name, email } = req.body;

  if (!name && !email) {
    throw new BadRequestError('Please provide a name or email to update');
  }

  // The user's ID comes from our authentication middleware
  const userId = req.user.id;

  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: { name, email },
  });

  res.status(StatusCodes.OK).json({ message: 'Profile updated successfully', user: updatedUser });
};