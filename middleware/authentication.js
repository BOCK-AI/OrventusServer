import jwt from "jsonwebtoken";
import { PrismaClient } from '@prisma/client';
import NotFoundError from "../errors/not-found.js";
import UnauthenticatedError from "../errors/unauthenticated.js";

const prisma = new PrismaClient();

export const authenticateUser = async (req, res, next) => {
  console.log('--- ENTERED authenticateUser MIDDLEWARE ---'); // <-- ADD THIS
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new UnauthenticatedError('Authentication invalid');
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    // Attach the user from the token's payload to the request object
    req.user = { id: payload.id, role: payload.role  };

    // --- The database check is now gone! ---
    console.log('--- TOKEN VERIFIED, CALLING next() ---'); // <-- ADD THIS
    next(); // Immediately grant access if token is valid.
  } catch (error) {
    // This will catch expired tokens or invalid signatures
    throw new UnauthenticatedError('Authentication invalid');
  }
};


